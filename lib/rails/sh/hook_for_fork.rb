module Rails
  module Sh
    module HookForFork
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