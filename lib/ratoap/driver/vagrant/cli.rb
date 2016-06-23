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
          redis.subscribe_with_timeout(5, "ratoap:client_conn") do |on|
            on.message do |channel, message|
              payload = JSON.parse(message)

              logger.info "  message: #{payload}"
              case payload['act']
              when 'wait'
                logger.info 'wait'
                redis_script_sha = payload['redis_script_shas']['get_connect_identity']
                logger.info redis_script_sha
                # redis.evalsha(redis_script_sha)
              when 'quit'
                logger.info 'quit'
                exit
              end
            end
          end

          0
        end
      end
    end
  end
end
