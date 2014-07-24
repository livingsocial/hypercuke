require 'hypercuke/version'
require 'hypercuke/cli'
require 'hypercuke/context'
require 'hypercuke/exceptions'
require 'hypercuke/mini_inflector'
require 'hypercuke/name_list'
require 'hypercuke/step_driver'
require 'hypercuke/step_adapter'
require 'hypercuke/step_adapters'
require 'hypercuke/adapter_definition'

module Hypercuke
  LAYER_NAME_ENV_VAR = 'HYPERCUKE_LAYER'

  def self.reset!
    @current_layer = nil
    layers.clear
    topics.clear
    StepAdapters.clear
  end

  def self.current_layer=(layer_name)
    @current_layer = layer_name ? layer_name.to_sym : nil
  end
  def self.current_layer
    layer_name = (@current_layer || ENV[LAYER_NAME_ENV_VAR])
    layer_name && layer_name.to_sym
  end


  def self.layers
    @layers ||= NameList.new
  end
  def self.layer_names
    layers.to_a
  end


  def self.topics
    @topics ||= NameList.new
  end
  def self.topic_names
    topics.to_a
  end
end
