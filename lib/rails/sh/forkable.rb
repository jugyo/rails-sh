module Rails
  module Sh
    module Forkable
      def invoke(line)
        run_before_fork
        pid = fork do
          run_after_fork
          _invoke(line)
        end
        Process.waitpid(pid)
      end

      def _invoke
        raise NotImplementedError
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