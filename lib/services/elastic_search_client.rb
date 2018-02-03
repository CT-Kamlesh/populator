class ElasticSearchClient
  include Singleton
  attr_reader :client

  def initialize
    @client = Elasticsearch::Client.new host: ENV['ES_HOST'], port: ENV['ES_PORT']
  end
end
