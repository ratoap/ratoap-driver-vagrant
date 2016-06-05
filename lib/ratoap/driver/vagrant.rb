require_relative "vagrant/version"

require "logger"
require "redis"

module Ratoap
  module Driver
    module Vagrant

      def self.logger
        @@logger ||= (
          Logger.new(STDOUT)
        )
      end

      def self.redis
        @@redis ||= (
          redis_config = {
            host: '127.0.0.1',
            port: 6379,
            db: 0,
          }

          Redis.new redis_config
        )
      end

    end
  end
end
