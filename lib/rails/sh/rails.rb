module Rails
  module Sh
    module Rails
      extend Forkable

      class << self
        def init
          before_fork do
            ActiveRecord::Base.remove_connection if defined?(ActiveRecord::Base)
          end
          after_fork do
            ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
          end
        end

        def _invoke(line)
          reload!
          ARGV.clear
          ARGV.concat line.split(/\s+/)
          puts "\e[42m$ rails #{ARGV.join(" ")}\e[0m"
          require 'rails/commands'
        end

        def reload!
          ActionDispatch::Callbacks.new(Proc.new {}, false).call({})
        end

        def sub_commands
          %w(generate destroy plugin benchmarker profiler
            console server dbconsole application runner)
        end
      end
    end
  end
end