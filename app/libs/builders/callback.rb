module Builders
  class Callback
    include ActiveSupport::Callbacks

    attr_accessor :on_success, :on_failure
    define_callbacks :on_success, :on_failure

    def success(&block)
      @on_success = Proc.new do |*args|
        run_callbacks :on_success do
          block.call(*args)
        end
      end
    end

    def failure(&block)
      @on_failure = Proc.new do |*args|
        run_callbacks :on_failure do
          block.call(*args)
        end
      end
    end

    private

    def initialize(args = {})
    end
  end
end
