module Hypercuke
  # Entry point for the adapter definition API
  def self.topic(topic_name, &block)
    AdapterDefinition.topic topic_name, &block
  end

  module AdapterDefinition
    def self.topic(topic_name, &block)
      Hypercuke.topics.define topic_name
      tb = TopicBuilder.new(topic_name)
      tb.instance_eval &block if block_given?
    end

    class TopicBuilder
      attr_reader :topic_name
      def initialize(topic_name)
        @topic_name = topic_name.to_sym
      end

      # I know the name *says* "layer", but what it *means* is that we
      # should define a step adapter for that layer.
      def layer(layer_name, &block)
        Hypercuke.layers.define layer_name
        klass = Hypercuke::StepAdapters.define( topic_name, layer_name )
        klass.module_eval &block if block_given?
      end
    end
  end
end
