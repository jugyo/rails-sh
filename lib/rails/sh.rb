require 'readline'
require 'rails/sh/forkable'
require 'rails/sh/rails'
require 'rails/sh/rake'
require 'rails/sh/command'
require 'rails/sh/bundler'

module Rails
  module Sh
    class << self
      def start
        ::Rails::Sh::Rails.init
        ::Rails::Sh::Rake.init

        require 'rails/sh/commands'

        puts "\e[36mRails.env: #{::Rails.env}\e[0m"
        puts "\e[36mtype `help` to print help\e[0m"

        setup_readline
        while buf = Readline.readline("rails-sh> ", true)
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
    end
  end
end
