module Hypercuke
  class CLI

    # I take information extracted the Parser and use it to build a
    # 'cucumber' command line
    class Builder
      def self.call(options)
        new(options).cucumber_command_line
      end

      def initialize(options)
        @options   = options
        @cuke_args = []
      end

      def cucumber_command_line
        add_base_command
        add_layer_tag_for_mode
        add_profile_unless_already_present
        pass_through_all_other_args

        cuke_args.join(' ')
      end

      private
      attr_reader :options, :cuke_args

      def add_base_command
        cuke_args << 'cucumber'
        cuke_args << '--require features/hypercuke'
      end

      def add_layer_tag_for_mode
        cuke_args << "--tags #{layer_tag_for_mode}"
      end

      def layer_tag_for_mode
        layer = options[:layer_name]
        mode  = options[:mode] || 'ok'
        '@%s_%s' % [ layer, mode ]
      end

      def add_profile_unless_already_present
        if profile_arg_present?
          add_profile options[:profile_name], options[:profile_arg]
        else
          if options[:mode] == 'wip'
            add_profile 'wip'
          end
        end
      end

      def profile_arg_present?
        options[:profile_arg].to_s !~ /^\s*$/
      end

      def add_profile(profile_name, profile_arg = '--profile')
        cuke_args << profile_arg
        cuke_args << profile_name
      end

      def pass_through_all_other_args
        cuke_args.concat( options[:other_args] )
      end
    end

  end
end
