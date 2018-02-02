require 'mongoid'
logger = Logger.new("log/#{'development'}.log")
Mongoid.load!("config/mongoid.yml", :development)
Mongoid.logger.level = Logger::DEBUG
Mongo::Logger.logger.level = Logger::DEBUG
