module Hypercuke

  # The step driver serves as the entry point from Cucumber step
  # definition bodies to the Hypercuke API.  An instance of this object
  # will be made available to Cucumber::World via the #step_driver
  # method.  
  #
  # The StepDriver should be created with a layer name.  It will
  # interpret any message sent to it as a topic name, combine that with
  # the layer name it already has, and use that to instantitate a
  # StepAdapter for the appropriate topic/layer combo.
  class StepDriver
    attr_accessor :layer_name
    def initialize(layer_name)
      if layer_name.nil? || layer_name =~ /^\s*$/
        fail ArgumentError, "Topic name is required"
      end
      self.layer_name = layer_name.to_sym
    end

    def method_missing(method, *_O) # No arguments for you, Mister Bond! *adjusts monocle*
      topic_name = method.to_sym

      # Define a method for the topic name so that future requests for
      # the same step adapter don't pay the method_missing tax.
      self.class.send(:define_method, topic_name) do
        # Within the defined method, memoize the step adapter so that
        # future requests also don't pay the GC tax.
        key = [topic_name, layer_name] # key on both names in case someone changes the layer on us
        __step_adapters__[key] ||=
          begin
            klass = Hypercuke.step_adapter_class(*key)
            klass.new(__context__, self)
          end
      end

      # And don't forget to invoke the newly-created method.
      send(method)
    end

    # StepDriver is eager to please.
    def respond_to_missing?(_)
      true
    end

    private

    def __context__
      @__context__ ||= Hypercuke::Context.new
    end

    def __step_adapters__
      @__step_adapters__ ||= {}
    end
  end
end
