module Rails
  module Sh
    module Bundler
      extend Forkable
      
      class << self
        def _invoke(line)
          line ||= 'install'
          command, *args = line.split(/\s+/)
          ARGV.clear
          ARGV.concat args
          require 'bundler/cli'
          ::Bundler::CLI.new.send(command.to_sym)
        end

        def sub_commands
          %w(exec install update open package config check list show console open viz init gem)
        end
      end
    end
  end
end