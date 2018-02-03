# frozen_string_literal: true
require "sidekiq"

uri = ENV["REDIS_URL"] || "redis://localhost:6379/0"
app_name = 'populator'

Sidekiq.configure_server do |config|
  config.redis = { url: uri, namespace: "#{app_name}_#{ENV['RACK_ENV']}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: uri, namespace: "#{app_name}_#{ENV['RACK_ENV']}" }
end
