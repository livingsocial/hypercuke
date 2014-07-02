require 'hypercuke/version'
require 'hypercuke/context'
require 'hypercuke/exceptions'
require 'hypercuke/mini_inflector'
require 'hypercuke/step_driver'
require 'hypercuke/step_adapter'
require 'hypercuke/step_adapters'
require 'hypercuke/adapter_definition'

module Hypercuke
  def self.reset!
    layers.clear
    topics.clear
    StepAdapters.clear
  end

  # NOTE: keep an eye on duplication between .layers and .topics

  def self.layers
    @layers ||= []
  end
  def self.name_layer(layer_name)
    name = layer_name.to_sym
    layers << name unless layers.include?(name)
  end
  def self.validate_layer_name(layer_name)
    name = layer_name.to_sym
    if Hypercuke.layers.include?(name)
      name
    else
      fail LayerNotDefinedError, "Layer not defined: #{name}"
    end
  end

  def self.topics
    @topics ||= []
  end
  def self.name_topic(topic_name)
    name = topic_name.to_sym
    topics << name unless topics.include?(name)
  end
  def self.validate_topic_name(topic_name)
    name = topic_name.to_sym
    if Hypercuke.topics.include?(name)
      name
    else
      fail TopicNotDefinedError, "Topic not defined: #{name}"
    end
  end
end
