require 'readline'
require 'rails/sh/patch_for_kernel'
require 'rails/sh/rake'
require 'rails/sh/command'
require 'rails/sh/commands'

module Rails
  module Sh
    RAILS_SUB_COMMANDS = ['generate', 'destroy', 'plugin', 'benchmarker', 'profiler', 
                          'console', 'server', 'dbconsole', 'application', 'runner']

    class << self
      def start
        Rails::Sh::Rake.init
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

      def setup_readline
        Readline.basic_word_break_characters = ""
        Readline.completion_proc = lambda do |word|
          (
            Command.command_names.map { |name| name.to_s } +
            RAILS_SUB_COMMANDS +
            Rails::Sh::Rake.task_names.map { |name| "rake #{name}" }
          ).grep(/#{Regexp.quote(word)}/)
        end
      end

      def execute(line)
        start = Time.now
        if command = Command.find(line)
          arg = line.split(/\s+/, 2)[1] rescue nil
          command.call(arg)
        else
          execute_rails_command(line)
        end
        puts "\e[34m#{Time.now - start}sec\e[0m"
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
