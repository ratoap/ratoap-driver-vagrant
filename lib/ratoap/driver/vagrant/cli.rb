module Ratoap
  module Driver
    module Vagrant
      module CLI
        def self.run(argv = ARGV)
          logger = Ratoap::Driver::Vagrant.logger
          redis = Ratoap::Driver::Vagrant.redis

          logger.info "subscribe ratoap:client_conn"
          redis.subscribe_with_timeout(5, "ratoap:client_conn") do |on|
            on.message do |channel, message|
              puts message
            end
          end

          0
        end
      end
    end
  end
end
