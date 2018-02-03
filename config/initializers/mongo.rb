require 'mongoid'
logger = Logger.new("log/#{ENV['RACK_ENV']}.log")
Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV'].downcase.to_sym)
Mongoid.logger.level = Logger::DEBUG
Mongo::Logger.logger.level = Logger::DEBUG
