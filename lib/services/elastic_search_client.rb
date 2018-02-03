class ElasticSearchClient
  include Singleton
  attr_reader :client

  def initialize
    @client = Elasticsearch::Client.new host: '184.73.150.94', port: 9200
  end
end
