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
    source = data['_source']
    begin
      state = State.find_or_create_by! name: source['state'].downcase.strip, district: source['district'].downcase.strip
      court_group = CourtGroup.find_or_create_by! category: source['court_group'].strip
      court_group.update({name: source['court']})

      cl = CauseList.find_or_initialize_by es_index: data['_index'], es_type: data['_type'], es_id: source['_id']
      cl.state = state
      cl.court_group = court_group

      %w[cl_id storage_id judges start_date end_date base_uri uri dated insert_time causelist_type
    extension court_location court].each do |w|
        cl.send "#{w}=", source[w]
      end

      kase = cl.cases.build({ number: source['case_no'], cnr: source['cnr'],
                              code: source['case_code'], category: source['case_type'] })
      if source['case_information']
        kase.build_case_information({ information: source['case_information'] })
      else
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
      if cl.save
        Sidekiq.logger.info '***********************************************************************'
      else
        Sidekiq.logger.info '=' * 50
        Sidekiq.logger.info cl.errors.inspect
      end
    rescue StandardError => e
      Sidekiq.logger.info '-' * 50
      Sidekiq.logger.info e.inspect
      Sidekiq.logger.info data.inspect
    end
  end

  private

  def generate_data(party_type:, parties:)
    parties.collect{|p| { category: party_type, name: p['name'], address: p['address'], advocate: p['advocate'] } }
  end
end
