require 'mongoid'
require 'elasticsearch'
require 'sidekiq'
require 'redis-namespace'
require 'pry'
require 'dotenv'

Dotenv.load

require_relative 'config/initializers/mongo'
require_relative 'config/initializers/sidekiq'
require_relative 'lib/workers/data_persister'
require_relative 'lib/services/elastic_search_client'
require_relative 'lib/models/cause_list'
require_relative 'lib/models/case'
require_relative 'lib/models/case_information'
require_relative 'lib/models/court_group'
require_relative 'lib/models/party'
require_relative 'lib/models/state'

class Main
  def process
    client = ElasticSearchClient.instance.client
    data = client.search index: 'in_cl_oldprd_supreme', scroll: '5m', size: 50, body: { sort: ['_doc'] }
    data['hits']['hits'].each{|r| schedule(r); sleep 0.3 }
    while data = client.scroll(body: { scroll_id: data['_scroll_id'] }, scroll: '5m') and not data['hits']['hits'].empty? do
      data['hits']['hits'].each{|r| schedule(r); sleep 0.3 }
    end
  end

  def schedule(data)
    DataPersister.set(wait: rand(0..100).seconds).perform_async data
  end
end

