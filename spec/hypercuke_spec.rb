require 'spec_helper'

describe Hypercuke do
  around do |example|
    layer = Hypercuke.current_layer
    begin
      example.run
    ensure
      Hypercuke.current_layer = layer
    end
  end

  describe "current layer" do
    it "can be set" do
      Hypercuke.current_layer = 'wibble'
      expect( Hypercuke.current_layer ).to eq( :wibble )
    end

    it "defaults to an environment variable" do
      expect( Hypercuke.current_layer ).to be nil
      begin
        ENV['HYPERCUKE_LAYER'] = 'flapjack_adjustment_station'
        expect( Hypercuke.current_layer ).to eq( :flapjack_adjustment_station )
      ensure
        ENV['HYPERCUKE_LAYER'] = nil
      end
    end
  end
end
