require 'forwardable'

module Hypercuke
  # I provide a way of passing state around between tests
  # that isn't instance variables.
  #
  # This is handy even in plain old Cucumber-land (where if you typo an
  # instance variable, you just get nil), and essential in a set of
  # mostly-independent step adapter objects, each with their own private
  # state.
  class Context
    def initialize
      @hash = {}
    end

    extend Forwardable
    # I support:
    # - Hash-style getting and setting via square brackets,
    # - fetch (as a pass-through to Hash),
    def_delegators :@hash, *[
      :[],
      :[]=,
      :fetch,
    ]

    # - And a variant of fetch that, if the key is not found, sets it
    #   for the next caller.
    #
    # This behavior is in the spirit of the ||= operator, except that
    # it won't short-circuit and call the default value if the key is
    # present, but set to nil or false.
    def fetch_or_default(key, &block)
      @hash[key] = @hash.fetch(key, &block)
    end
  end
end
