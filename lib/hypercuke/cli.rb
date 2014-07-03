require 'hypercuke/cli/parser'
require 'hypercuke/cli/builder'

module Hypercuke
  class CLI
    def cucumber_command(hcu_command)
      options = parser.call(hcu_command)
      builder.call(options)
    end

    private

    def parser
      Hypercuke::CLI::Parser
    end

    def builder
      Hypercuke::CLI::Builder
    end
  end
end
