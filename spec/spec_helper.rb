require_relative '../lib/hypercuke'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect # I hate Kernel#should with the fire of a thousand suns
  end
end
