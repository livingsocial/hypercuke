require 'hypercuke/version'
require 'hypercuke/cli'
require 'hypercuke/context'
require 'hypercuke/exceptions'
require 'hypercuke/mini_inflector'
require 'hypercuke/step_driver'
require 'hypercuke/step_adapter'
require 'hypercuke/step_adapters'
require 'hypercuke/adapter_definition'

module Hypercuke
  LAYER_NAME_ENV_VAR = 'HYPERCUKE_LAYER'
  extend self

  def reset!
    @current_layer = nil
    layers.clear
    topics.clear
    StepAdapters.clear
  end

  def current_layer=(layer_name)
    @current_layer = layer_name ? layer_name.to_sym : nil
  end
  def current_layer
    layer_name = (@current_layer || ENV[LAYER_NAME_ENV_VAR])
    layer_name && layer_name.to_sym
  end

  # NOTE: keep an eye on duplication between .layers and .topics

  def layers
    @layers ||= []
  end
  def name_layer(layer_name)
    name = layer_name.to_sym
    layers << name unless layers.include?(name)
  end
  def validate_layer_name(layer_name)
    name = layer_name.to_sym
    if Hypercuke.layers.include?(name)
      name
    else
      fail LayerNotDefinedError, "Layer not defined: #{name}"
    end
  end

  def topics
    @topics ||= []
  end
  def name_topic(topic_name)
    name = topic_name.to_sym
    topics << name unless topics.include?(name)
  end
  def validate_topic_name(topic_name)
    name = topic_name.to_sym
    if Hypercuke.topics.include?(name)
      name
    else
      fail TopicNotDefinedError, "Topic not defined: #{name}"
    end
  end
end
