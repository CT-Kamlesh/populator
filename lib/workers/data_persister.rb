require_relative '../../main'
require 'rails/mongoid'

class DataPersister
  include Sidekiq::Worker

  Mongoid.load!("config/mongoid.yml", :development)

  sidekiq_options retry: 2

  # The current retry count is yielded. The return value of the block must be
  # an integer. It is used as the delay, in seconds.
  sidekiq_retry_in do |count|
    5 * (count + 1) # (i.e. 10, 20, 30, 40, 50)
  end

  def perform(data)
    Sidekiq.logger.info '#' * 40
    source = data['_source']
    Sidekiq.logger.info data.inspect
    begin
      state = State.find_or_create_by! name: source['state'].downcase.strip, district: source['district'].downcase.strip
      court_group = CourtGroup.find_or_create_by! category: source['court_group'].downcase.strip
      court_group.update({name: source['court'].strip})

      cl = CauseList.find_or_initialize_by es_index: data['_index'], es_type: data['_type'], storage_id: source['storage_id'].strip
      # if cause list doesnt exist then assign attributes
      if cl.new_record?
        cl.state = state
        cl.court_group = court_group
        cl.es_id = data['_id']

        %w[cl_id storage_id judges start_date end_date base_uri uri dated insert_time causelist_type clauselist_type
    extension court_location court].each do |w|
          cl.send "#{w}=", source[w].try(:strip) if source[w]
        end
      end

      kase = cl.cases.build({ number: source['case_no'].try(:strip), cnr: source['cnr'].try(:strip),
                              code: source['case_code'].try(:strip), category: source['case_type'].try(:strip) })
      unless kase.valid?
        Sidekiq.logger.info 'kase-error' * 30
        Sidekiq.logger.info kase.errors.inspect
      end

      if source['case_information'].nil? && source['petitioners'].nil? && source['respondents'].nil?
        Sidekiq.logger.info 'ERROR!!!'
        Sidekiq.logger.info 'Case informantion, petitioners and respondents are missing for the case'
      end
      if source['case_information']
        kase.build_case_information({ information: source['case_information'].try(:strip) })
      else
        Sidekiq.logger.info 'petitioners/respondents/' * 10
        Sidekiq.logger.info source['petitioners'].inspect
        Sidekiq.logger.info source['respondents'].inspect
        if source['petitioners']
          petitioners = generate_data(:petitioner, source['petitioners'].uniq)
          kase.parties.build petitioners
        end
        if source['respondents']
          respondents = generate_data(:respondent, source['respondents'].uniq)
          kase.parties.build respondents
        end
      end
      #TODO: persist casestatus_params
      Sidekiq.logger.info 'summary-' * 10
      Sidekiq.logger.info "Case: #{kase.valid?}"
      Sidekiq.logger.info "Case information: #{kase.case_information.valid?}"
      Sidekiq.logger.info "Cause List: #{cl.valid?}"
      if cl.save
        Sidekiq.logger.info '**************************************'
        Sidekiq.logger.info "PERSISTED"
        Sidekiq.logger.info "Cause List: #{cl.persisted?}"
        Sidekiq.logger.info "Case: #{kase.persisted?}"
        Sidekiq.logger.info "Case information: #{kase.case_information.persisted?}"
      else
        Sidekiq.logger.info 'INVALID--' * 20
        Sidekiq.logger.info cl.errors.inspect
      end
    rescue StandardError => e
      Sidekiq.logger.info '!@#!@#' * 20
      Sidekiq.logger.info '!@#!@#' * 20
      Sidekiq.logger.info e.inspect
      Sidekiq.logger.info data.inspect
    end
  end

  private

  def generate_data(party_type:, parties:)
    parties.collect{|p| { category: party_type, name: p['name'], address: p['address'], advocate: p['advocate'] } }
  end
end
