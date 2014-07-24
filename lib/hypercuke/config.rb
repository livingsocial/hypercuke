module Hypercuke

  class Config
    attr_reader :layers, :topics
    def initialize
      @layers = NameList.new
      @topics = NameList.new
    end

    def layer_names
      layers.to_a
    end

    def topic_names
      topics.to_a
    end

  end

end
