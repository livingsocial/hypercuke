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


  def layers
    @layers ||= NameList.new
  end
  def layer_names
    layers.to_a
  end


  def topics
    @topics ||= NameList.new
  end
  def topic_names
    topics.to_a
  end
end
