module Hypercuke
  module Error
    def self.included(receiver)
      receiver.extend ClassMethods
    end

    module ClassMethods
      def wrap(exception)
        message = translate_message(exception.message)
        new(message).tap do |wrapping_exception|
          wrapping_exception.set_backtrace exception.backtrace
        end
      end

      def translate_message(message)
        message # just here to be overridden
      end
    end
  end

  class TopicNotDefinedError < NameError
    include Hypercuke::Error

    def self.translate_message(message)
      topic_name =
        if md = /Hypercuke::StepAdapters::(.*)/.match(message)
          md.captures.first
        else
          message
        end
      "Topic not defined: '#{topic_name}'"
    end
  end

  class StepAdapterNotDefinedError < NameError
    include Hypercuke::Error

    def self.translate_message(message)
      step_adapter_name = 
        if md = /Hypercuke::StepAdapters::(.*)/.match(message)
          md.captures.first
        else
          message
        end
      "Step adapter not defined: '#{step_adapter_name}'"
    end
  end
end
