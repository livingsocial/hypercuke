# NOTE:  this file should not be required from the Hypercuke gem itself.
# It's intended to be required from within the Cucumber environment
# (e.g., in features/support/env.rb or equivalent).

module Hypercuke
  module CucumberIntegration
    module WorldMixin
      def step_driver
        @step_driver ||= Hypercuke::StepDriver.new
      end
    end
  end
end

World( Hypercuke::CucumberIntegration::WorldMixin )
