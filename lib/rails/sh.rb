require 'rails/sh/command'
require 'rails/sh/patch_for_kernel'
require 'readline'

module Rails
  module Sh
    RAILS_SUB_COMMANDS = ['generate', 'destroy', 'plugin', 'benchmarker', 'profiler', 
                          'console', 'server', 'dbconsole', 'application', 'runner']

    class << self
      def start
        puts "Rails.env: #{Rails.env}"
        puts "type `help` to print help"
        setup_readline
        while buf = Readline.readline("\e[42mrails>\e[0m ", true)
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

      def setup_readline
        Readline.basic_word_break_characters = ""
        Readline.completion_proc = lambda do |word|
          (Command.command_names + RAILS_SUB_COMMANDS).grep(/^#{Regexp.quote(word)}/)
        end
      end

      def execute(line)
        if command = Command.find(line)
          arg = line[/\s+[^\s]+/].strip rescue nil
          command.call(arg)
        else
          execute_rails_command(line)
        end
      end

      def execute_rails_command(line)
        ENV.delete("RAILS_ENV")
        ARGV.clear
        ARGV.concat line.split(/\s+/)
        puts "\e[42m$ rails #{ARGV.join(" ")}\e[0m"
        clear_dependencies
        load 'rails/commands.rb'
      end

      def clear_dependencies
        ActiveSupport::DescendantsTracker.clear
        ActiveSupport::Dependencies.clear
      end
    end
  end
end
