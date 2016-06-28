require 'optparse'
require 'ostruct'
require 'json'

module Ratoap
  module Driver
    module Vagrant


      module CLI
        def self.argv_parse(args)
          options = OpenStruct.new

          opt_parser = OptionParser.new do |opts|
            opts.on("-l", "--logger file", String, "Set logger file") do |logger|
              options.logger = logger
            end
          end

          opt_parser.parse!(args)
          options
        end

        def self.run(args = ARGV)
          options = argv_parse(args)

          logger = Ratoap::Driver::Vagrant.logger options.logger
          redis = Ratoap::Driver::Vagrant.redis

          logger.info "subscribe ratoap:client_conn"
          redis.subscribe("ratoap:client_conn") do |on|
            on.subscribe do |channel, subscriptions|
              logger.info "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
            end

            on.message do |channel, message|
              payload = JSON.parse(message)
              logger.info "##{channel}: #{payload}"

              case payload['act']
              when 'wait'
                logger.info 'wait'
                Process.fork do
                  redis = Ratoap::Driver::Vagrant.fork_redis
                  get_conn_identity_redis_script_sha = payload['redis_script_shas']['get_conn_identity']
                  r = redis.evalsha(get_conn_identity_redis_script_sha, {argv: ['driver', 'vagrant_ruby', 'xxx']})
                  logger.info "conn_identity: #{get_conn_identity_redis_script_sha} #{r}"
                end
              when 'quit'
                logger.info 'quit'
                redis.unsubscribe("ratoap:client_conn")
              end
            end

            on.unsubscribe do |channel, subscriptions|
              logger.info "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
            end
          end

          logger.info 'driver-vagrant exit'
        end
      end
    end
  end
end
