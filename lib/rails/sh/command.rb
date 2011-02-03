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
      end
    end
  end
end