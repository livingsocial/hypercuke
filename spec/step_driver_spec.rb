require 'spec_helper'

describe Hypercuke::StepDriver do
  before do
    Hypercuke.topic :wibble do
      layer :spam  do ; def wibble ; "wibble spam"  ; end ; end
      layer :eggs  do ; def wibble ; "wibble eggs"  ; end ; end
      layer :bacon do ; def wibble ; "wibble bacon" ; end ; end
    end
    Hypercuke.topic :yak do
      layer :spam  do ; def shave ; "s*MOO*th spam"  ; end ; end
      layer :eggs  do ; def shave ; "s*MOO*th eggs"  ; end ; end
      # Is yak bacon even a thing?  ...wait, don't answer that.
    end
    Hypercuke.current_layer = :spam
  end


  subject(:step_driver) { described_class.new }

  describe "step adapter retrieval" do

    it "asks Hypercuke for the current layer" do
      Hypercuke.current_layer = :bacon
      expect( step_driver.layer_name ).to eq( :bacon )
    end

    it "can return a step adapter for each layer" do
      expect( step_driver.wibble.wibble ).to eq( "wibble spam" )
      expect( step_driver.yak.shave ).to eq( "s*MOO*th spam" )
    end

    it "explodes when asked for a topic that isn't defined" do
      expect{ step_driver.heffalump }.to raise_error( Hypercuke::TopicNotDefinedError, "Topic not defined: heffalump" )
    end

    it "explodes when asked for a layer that isn't defined" do
      Hypercuke.current_layer = :booOOoogus
      expect{ step_driver.wibble }.to raise_error( Hypercuke::LayerNotDefinedError, "Layer not defined: booOOoogus" )
    end

    it "explodes when asked for a step adapter that isn't defined at the current layer" do
      Hypercuke.current_layer = :bacon
      expect( step_driver.wibble ).to be_kind_of( Hypercuke::StepAdapters::Wibble::Bacon )
      expect{ step_driver.yak }.to raise_error( Hypercuke::StepAdapterNotDefinedError, "Step adapter not defined: 'Hypercuke::StepAdapters::Yak::Bacon'" )
    end

    it "can return a step adapter for each layer (even when the layer is changed)" do
      [ :spam, :eggs, :bacon ].each do |layer|
        Hypercuke.current_layer = layer
        expect( step_driver.wibble.wibble ).to eq( "wibble #{layer}" )
        expect( step_driver.yak.shave ).to eq( "s*MOO*th #{layer}" ) unless :bacon == layer
      end
    end

  end

  describe "context management" do
    let(:sd_context) { step_driver.send(:__context__) }

    specify "step driver has a context" do
      expect( sd_context ).to be_kind_of( Hypercuke::Context )
    end

    specify "step driver passes its context to any step adapter it creates" do
      step_adapter_context = step_driver.wibble.__send__(:context)
      expect( step_adapter_context ).to be( sd_context )
    end
  end

  describe "inter-adapter dependencies" do
    before do
      Hypercuke.reset!
      Hypercuke.topic :bikeshed do
        layer :distraction do
          def color ; "blue" ; end
        end
        layer :planet_ruby do
          def color ; "ruby red" ; end # HINT: the herring is red, too...
        end
      end
      Hypercuke.topic :yak do
        layer :distraction do
          def bikeshed_color
            step_driver.bikeshed.color
          end
        end
      end
      Hypercuke.current_layer = :distraction
    end

    let(:step_driver) { described_class.new }

    specify "step adapters within the same layer may access one another through the step driver" do
      expect( step_driver.yak.bikeshed_color ).to eq( "blue" )
    end
  end

end
