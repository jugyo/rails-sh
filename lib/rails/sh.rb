require 'readline'
require 'rails/sh/hook_for_fork'
require 'rails/sh/rake'
require 'rails/sh/command'

module Rails
  module Sh
    extend HookForFork

    class << self
      def start
        before_fork do
          ActiveRecord::Base.remove_connection if defined?(ActiveRecord::Base)
        end
        after_fork do
          ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
        end

        init_rake

        require 'rails/sh/commands'

        puts "Rails.env: #{Rails.env}"
        puts "type `help` to print help"

        setup_readline
        while buf = Readline.readline("rails> ", true)
          line = buf.strip
          next if line.empty?
          begin
            execute(line)
          rescue SystemExit
            raise
          rescue Exception => e
            puts "\e[41m#{e.message}\n#{e.backtrace.join("\n")}\e[0m"
          end
          setup_readline
        end
      end

      def init_rake
        Rails::Sh::Rake.init
        Rails::Sh::Rake.before_fork do
          run_before_fork
        end
        Rails::Sh::Rake.after_fork do
          run_after_fork
        end
      end

      def setup_readline
        Readline.basic_word_break_characters = ""
        Readline.completion_proc = Command.completion_proc
      end

      def execute(line)
        if command = Command.find(line)
          start = Time.now
          arg = line.split(/\s+/, 2)[1] rescue nil
          command.call(arg)
          puts "\e[34m#{Time.now - start}sec\e[0m"
        else
          puts "\e[41mCommand not found\e[0m"
        end
      end

      def execute_rails_command(line)
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
    end
  end
end
