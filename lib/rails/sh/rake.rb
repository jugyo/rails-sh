require 'rake'
require 'stringio'

module Rails
  module Sh
    module Rake
      extend HookForFork

      class << self
        def init
          $stdout = StringIO.new
          ::Rake.application = ::Rake::Application.new
          ::Rake.application.init
          ::Rake.application.load_rakefile
          ::Rake.application[:environment].invoke
        ensure
          $stdout = STDOUT
        end

        def invoke(line)
          name, *args = line.split(/\s+/)
          run_before_fork
          pid = fork do
            run_after_fork
            args.each do |arg|
              env, value = arg.split('=')
              next unless env && !env.empty? && value && !value.empty?
              ENV[env] = value
            end
            ::Rake.application[name].invoke
          end
          Process.waitpid(pid)
        end

        def task_names
          ::Rake.application.tasks.map{|t| t.name}
        end
      end
    end
  end
end