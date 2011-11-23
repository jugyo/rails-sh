module Rails
  module Sh
    module Helpers
      # copy from pry: https://github.com/pry/pry
      #
      # Create scrollable output via less!
      #
      # This command runs `less` in a subprocess, and gives you the IO to its STDIN pipe
      # so that you can communicate with it.
      #
      # Example:
      #
      #   lesspipe do |less|
      #     50.times { less.puts "Hi mom!" }
      #   end
      #
      # The default less parameters are:
      # * Allow colour
      # * Don't wrap lines longer than the screen
      # * Quit immediately (without paging) if there's less than one screen of text.
      #
      # You can change these options by passing a hash to `lesspipe`, like so:
      #
      #   lesspipe(:wrap=>false) { |less| less.puts essay.to_s }
      #
      # It accepts the following boolean options:
      #    :color  => Allow ANSI colour codes?
      #    :wrap   => Wrap long lines?
      #    :always => Always page, even if there's less than one page of text?
      #
      def lesspipe(*args)
        if args.any? and args.last.is_a?(Hash)
          options = args.pop
        else
          options = {}
        end

        output = args.first if args.any?

        params = []
        params << "-R" unless options[:color] == false
        params << "-S" unless options[:wrap] == true
        params << "-F" unless options[:always] == true
        if options[:tail] == true
          params << "+\\>"
          $stderr.puts "Seeking to end of stream..."
        end
        params << "-X"

        IO.popen("less #{params * ' '}", "w") do |less|
          if output
            less.puts output
          else
            yield less
          end
        end
      end
    end
  end
end
