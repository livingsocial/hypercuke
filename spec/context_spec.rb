require 'spec_helper'

describe Hypercuke::Context do
  subject { Hypercuke::Context.new }

  it "allows square-bracket setting and getting, same as a Hash" do
    expect( subject[:wibble] ).to be nil
    subject[:wibble] = 'wibble'
    expect( subject[:wibble] ).to eq( 'wibble' )
  end

  let(:ransom_1960s) { "one MILLION dollars" }
  let(:ransom_1990s) { "one hundred billion dollars" }

  it "behaves like a Hash with regard to #fetch" do
    subject[:demand] = ransom_1960s
    expect( subject.fetch(:demand) ).to eq( ransom_1960s )

    expect{ subject.fetch(:updated_demand) }
      .to raise_error( KeyError )
    result = subject.fetch(:updated_demand) { ransom_1990s }
    expect( result ).to eq( ransom_1990s )
  end

  describe "#fetch_or_default" do
    before do
      subject[:demand] = ransom_1960s 
    end

    describe "when asked for a key that exists" do
      it "returns the value without calling the block" do
        result = subject.fetch_or_default(:demand) { fail "this block should not be called" }
        expect( result ).to eq( ransom_1960s )
      end
    end

    describe "when asked for a key that does not exist" do
      it "calls the block, sets the key, and returns the value" do
        result = subject.fetch_or_default(:updated_demand) { ransom_1990s }
        expect( result ).to eq( ransom_1990s )
        result = subject.fetch_or_default(:updated_demand) { fail "this block should not be called" }
        expect( result ).to eq( ransom_1990s )
      end
    end
  end
end
