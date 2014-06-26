require "hypercuke/version"
require 'hypercuke/step_driver'
require 'hypercuke/step_drivers'
require 'hypercuke/driver_definition'

module Hypercuke
  def self.reset!
    layers.clear
    topics.clear
    StepDrivers.clear
  end

  # NOTE: keep an eye on duplication between .layers and .topics

  def self.layers
    @layers ||= []
  end
  def self.name_layer(layer_name)
    name = layer_name.to_sym
    layers << name unless layers.include?(name)
  end

  def self.topics
    @topics ||= []
  end
  def self.name_topic(topic_name)
    name = topic_name.to_sym
    topics << name unless topics.include?(name)
  end
end
