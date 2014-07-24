require 'forwardable'

module Hypercuke
  class NameList
    attr_reader :names
    private :names

    def initialize(*names)
      @names = names.flatten
    end

    def define(new_name)
      name = new_name.to_sym
      names << name unless names.include?(name)
    end

    def validate(name)
      if valid_name?(name)
        return name.to_sym
      else
        yield if block_given?
        return nil
      end
    end

    def valid_name?(name)
      names.include?(name.to_sym)
    end

    def to_a
      names.dup
    end

    def empty?
      names.empty?
    end
  end
end
