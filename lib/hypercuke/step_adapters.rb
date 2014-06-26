module Hypercuke
  # Greetings, dear reader.  There's a lot going in this file, so it's
  # been organized in a more conversational style than most of the Ruby
  # code I write.  I hope it helps.

  # Provide a namespace for step adapters.  As new step adapter classes
  # are created (see Hypercuke::AdapterDefinition), they will be
  # assigned to constants in this module (so that they can have
  # human-friendly names when something goes wrong and #inspect gets
  # called on them).
  module StepAdapters
    # More on this topic later.  But first...
  end

  # Should you find yourself in possession of a [topic, layer] name
  # pair, this method allows you to redeem it for VALUABLE PRIZES!  (And
  # by "valuable prizes", I mean "a reference to a step adapter class,
  # if one has already been defined.")
  #
  # This method is but a facade...
  def self.step_adapter_class(topic_name, layer_name)
    StepAdapters.fetch(topic_name, layer_name)
  end

  # ...and here's what the facade hides.
  module StepAdapters
    # Turn [ :widgets, :core ] into self::Widgets::Core
    def self.fetch(topic_name, layer_name)
      topic_module = const_get(camelize(topic_name))
      topic_module.const_get(camelize(layer_name))
    end

    private

    def self.camelize(name)
      name.to_s.split('_').map(&:capitalize).join
    end
  end

  # When testing code that defines classes and binds them to constants,
  # it is occasionally useful to reset to a blank slate.
  module StepAdapters
    def self.clear
      constants.each do |c|
        remove_const c
      end
    end
  end

  # And now we get to the really fun part:  allowing us to say "I want a
  # step adapter for this topic/layer pair.  If it doesn't exist, go
  # ahead and define it; if it does, just give me the same one again."
  # (This idempotent behavior lets us reopen step adapter classes in the
  # adapter definition API.)

  # Here's the relevant bit of plumbing.  Feel free to ignore it...
  module ConstGetWithBlock
    def const_get(sym, inherit = true)
      super
    rescue NameError
      fail unless block_given?
      const_set sym, yield # NB: const_set returns the value
    end
  end

  # More plumbing; this is a convenient place for putting that behavior in a module
  # without having to call #extend on a bunch of new modules...
  class TopicModule < Module
    include ConstGetWithBlock
  end

  # ...and with that out of the way, this can be relatively short.
  module StepAdapters
    extend ConstGetWithBlock

    def self.let_there_be(topic_name, layer_name)
      # Note: there's some duplication here with .fetch (defined above).
      # Attempting to DRY it up will probably make it worse, but it's
      # worth keeping an eye on.
      topic_module = const_get(camelize(topic_name)) { TopicModule.new }
      topic_module.const_get(camelize(layer_name)) { Class.new(StepAdapter) }
    end
  end
end
