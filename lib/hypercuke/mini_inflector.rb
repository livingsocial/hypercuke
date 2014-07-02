module Hypercuke
  module MiniInflector
    extend self

    def camelize(name)
      name.to_s.split('_').map(&:capitalize).join
    end
  end
end
