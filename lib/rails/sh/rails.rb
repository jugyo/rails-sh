module Rails
  module Sh
    module Rails
      extend HookForFork

      class << self
        def invoke(line)
          run_before_fork
          pid = fork do
            run_after_fork
            reload!
            ARGV.clear
            ARGV.concat line.split(/\s+/)
            puts "\e[42m$ rails #{ARGV.join(" ")}\e[0m"
            require 'rails/commands'
          end
          Process.waitpid(pid)
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