require 'hypercuke/cli/parser'
require 'hypercuke/cli/builder'

module Hypercuke
  class CLI
    def self.exec(argv, opts = {})
      cli = new(argv, opts[:output_to])
      cli.run!
    end

    # NB: .bundler_present? is not covered by tests, because I can't
    # think of a reasonable way to test it.  PRs welcome.  :)
    def self.bundler_present?
      !! (`which bundle` =~ /bundle/) # parens are significant
    end

    def initialize(argv, output = nil, environment = ENV, kernel = Kernel)
      @argv        = argv
      @output      = output
      @environment = environment
      @kernel      = kernel
    end

    def run!
      output && output.puts(cucumber_command_with_env_var)
      environment[Hypercuke::LAYER_NAME_ENV_VAR] = layer_name
      kernel.exec cucumber_command
    end

    def layer_name
      parser.layer_name
    end

    def cucumber_command
      builder.cucumber_command_line(self.class.bundler_present?)
    end

    def cucumber_command_with_env_var
      "HYPERCUKE_LAYER=#{layer_name} #{cucumber_command}"
    end

    private
    attr_reader :argv, :output, :environment, :kernel

    def parser
      @parser ||= Hypercuke::CLI::Parser.new(argv)
    end

    def builder
      @builder ||= Hypercuke::CLI::Builder.new(parser.options)
    end
  end
end
