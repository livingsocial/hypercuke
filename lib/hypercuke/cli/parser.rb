module Hypercuke
  class CLI

    # I extract relevant information from a 'hcu' command line
    class Parser
      def self.call(hcu_command)
        new(hcu_command).parse_options
      end

      def initialize(hcu_command)
        @tokens = tokenize(hcu_command)
      end

      def parse_options
        fail "nope" if tokens.empty?
        @options = Hash.new

        ignore_hcu
        set_layer_name
        set_mode_if_present
        set_profile_if_present
        set_other_args

        options
      end

      private
      attr_reader :tokens, :options

      # That's 4 years of CS education right there, baby
      def tokenize(input)
        input.split(/\s+/).compact
      end

      # We might get the 'hcu' command name itself; just drop it on the floor
      def ignore_hcu
        tokens.shift if tokens.first =~ /^hcu$/i
      end

      # This is the only required argument.
      # TODO: Validate this against the list of known layers?
      #       ^ Would require loading local app's hypercuke config.
      #       ^ Would require allowing local app to *have* hypercuke config.
      def set_layer_name
        fail "Layer name is required" if tokens.empty?
        options[:layer_name] = tokens.shift
      end

      def set_mode_if_present
        unless tokens.first =~ /^-/
          options[:mode] = tokens.shift
        end
      end

      def set_profile_if_present
        if profile_index = ( tokens.index('--profile') || tokens.index('-p') )
          options[:profile_arg]  = tokens.delete_at(profile_index)
          options[:profile_name] = tokens.delete_at(profile_index)
        end
      end

      def set_other_args
        options[:other_args] = Array.new.tap do |rest|
          rest << tokens.shift until tokens.empty?
        end
      end
    end

  end
end
