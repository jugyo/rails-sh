require 'rake'
require 'stringio'

module Rails
  module Sh
    module Rake
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

        def before_fork(&block)
          @before_fork = block
        end

        def after_fork(&block)
          @after_fork = block
        end

        def run_before_fork(&block)
          @before_fork.call if @before_fork
        end

        def run_after_fork(&block)
          @after_fork.call if @after_fork
        end
      end
    end
  end
end