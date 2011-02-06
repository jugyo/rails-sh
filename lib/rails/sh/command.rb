module Rails
  module Sh
    module Command
      class << self
        def commands
          @commands ||= {}
        end

        def define(*names, &block)
          names.each do |name|
            commands[name.to_sym] = block
            completions << name.to_s
          end
        end

        def find(line)
          if name = line.split(/\s+/, 2)[0]
            commands[name.to_sym]
          else
            nil
          end
        end

        def command_names
          commands.keys
        end

        def [](name)
          commands[name.to_sym]
        end

        def completion_proc
          lambda { |line| completions.grep(/#{Regexp.quote(line)}/) }
        end

        def completions
          @completions ||= []
        end

        def completions=(completions)
          @completions = completions
        end

        def clear
          commands.clear
          completions.clear
        end
      end
    end
  end
end