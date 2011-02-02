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

        def invoke(name)
          Process.waitpid(fork { ::Rake.application[name].invoke })
        end

        def task_names
          ::Rake.application.tasks.map{|t| t.name}
        end
      end
    end
  end
end