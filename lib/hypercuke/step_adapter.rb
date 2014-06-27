module Hypercuke
  # I am the superclass for all of the generated step adapters.
  class StepAdapter
    def initialize(context = nil) # TODO: require context!
      @context = context
    end

    private
    attr_reader :context
  end
end
