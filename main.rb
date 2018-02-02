require 'mongoid'
require 'elasticsearch'
require 'sidekiq'
require 'redis-namespace'
require 'pry'
require 'dotenv'

Dotenv.load

require_relative 'config/initializers/sidekiq'
require_relative 'lib/models/cause_list'
require_relative 'lib/models/case'
require_relative 'lib/models/case_information'
require_relative 'lib/models/court_group'
require_relative 'lib/models/party'
require_relative 'lib/models/state'

