module Hypercuke
  # I am the superclass for all of the generated step adapters.
  class StepAdapter
    def initialize(context, step_driver)
      @context     = context
      @step_driver = step_driver
    end

    private
    attr_reader :context, :step_driver
  end
end
