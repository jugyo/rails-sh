require 'rails/sh/command'
require 'rails/sh/patch_for_require'
require 'readline'

module Rails
  module Sh
    RAILS_SUB_COMMANDS = ['generate', 'destroy', 'plugin', 'benchmarker', 'profiler', 
                          'console', 'server', 'dbconsole', 'application', 'runner']

    def self.start
      Readline.basic_word_break_characters = ""
      Readline.completion_proc = lambda do |word|
        (Command.command_names + RAILS_SUB_COMMANDS).grep(/^#{Regexp.quote(word)}/)
      end

      while buf = Readline.readline("\e[42mrails>\e[0m ", true)
        execute(buf)
      end
    end

    def self.execute(line)
      line = line.strip
      if command = Command.find(line)
        arg = line[/\s+\w+/].strip rescue nil
        command.call(arg)
      else
        execute_rails_command(line)
      end
    end

    def self.execute_rails_command(line)
      ENV.delete("RAILS_ENV")
      ARGV.clear
      ARGV.concat line.split(/\s+/)
      puts "\e[42m$ rails #{ARGV.join(" ")}\e[0m"
      load 'rails/commands.rb'
    end
  end
end
