require 'spec_helper'

describe "step adapter definition API" do
  subject { Hypercuke }

  # NAMING THINGS
  #
  # Top-level object available as #driver: Step Driver
  # Area of domain: Topic
  # Layer of application: Layer
  # Intersection of the two:  StepAdapter
  # Name of generated step adapter: Hypercuke::StepAdapters::<Topic>::<Layer>
  #
  #     L               T O P I C S
  #     A |       | Cheese     | Wine | Bread |
  #     Y | Core  | SA*        | SA*  | SA*   |
  #     E | Model | SA*        | SA*  | SA*   |
  #     R | UI    | SA*        | SA*  | SA*   |
  #     S
  #           * SA = StepAdapter

  context "when empty" do
    before do
      subject.topic :wibble # make sure it's not empty
      subject.reset!
    end

    it "has no layers when it starts" do
      expect( subject.layers ).to be_empty
    end
    it "has no topics when it starts" do
      expect( subject.topics ).to be_empty
    end
    it "has no step adapters when it starts" do
      expect( subject::StepAdapters.constants ).to be_empty
    end
  end

  context "with a single adapter in a single layer" do
    before do
      subject.topic :cheese do
        layer :core do
          def select_variety
            "It's hard to go wrong with cheddar."
          end
        end
      end
    end
    after do
      subject.reset!
    end

    let(:sd_class) { subject.step_adapter_class( :cheese, :core ) }

    it "defines a cheese topic" do
      expect( subject.topics ).to eq( [:cheese] )
    end

    it "defines a core layer" do
      expect( subject.layers ).to eq( [:core] )
    end

    it "defines a step adapter class for the cheese/core combo" do
      expect( sd_class ).to_not be_nil
      expect( sd_class.superclass ).to be( Hypercuke::StepAdapter )
      expect( sd_class.instance_methods(false) ).to eq( [ :select_variety ] )
    end

    it "allows the step adapter to be reopened" do
      subject.topic :cheese do
        layer :core do
          def pair_with(wine)
            "I probably should pick an example I know more about"
          end
        end
      end

      expect( sd_class.instance_methods(false).sort ).to eq( [ :select_variety, :pair_with ].sort )
    end

    it "gives the step adapter class a reasonable name" do
      expect( sd_class.name ).to eq( "Hypercuke::StepAdapters::Cheese::Core" )
    end
  end

  context "with two topics and three layers" do
    before do
      subject.topic :wibble do
        layer :spam  do ; def wibble ; "wibble spam"  ; end ; end
        layer :eggs  do ; def wibble ; "wibble eggs"  ; end ; end
        layer :bacon do ; def wibble ; "wibble bacon" ; end ; end
      end
      subject.topic :yak do
        layer :spam  do ; def shave ; "s*MOO*th spam"  ; end ; end
        layer :eggs  do ; def shave ; "s*MOO*th eggs"  ; end ; end
      end
    end
    after do
      subject.reset!
    end

    it "defines topic names" do
      expect( subject.topics ).to eq( [:wibble, :yak] )
    end

    it "defines layer names" do
      expect( subject.layers ).to eq( [:spam, :eggs, :bacon] )
    end

    it "defines step adapter classes with reasonable class names" do
      expect( Hypercuke::StepAdapters::Wibble::Spam .superclass ).to be( Hypercuke::StepAdapter )
      expect( Hypercuke::StepAdapters::Wibble::Eggs .superclass ).to be( Hypercuke::StepAdapter )
      expect( Hypercuke::StepAdapters::Wibble::Bacon.superclass ).to be( Hypercuke::StepAdapter )

      expect( Hypercuke::StepAdapters::Yak::Spam .superclass ).to be( Hypercuke::StepAdapter )
      expect( Hypercuke::StepAdapters::Yak::Eggs .superclass ).to be( Hypercuke::StepAdapter )
      expect{ Hypercuke::StepAdapters::Yak::Bacon }.to raise_error(NameError)
    end
  end

  context "naming conflicts" do
    after do
      Hypercuke.reset!
    end

    it "works when a topic name resolves to something outside the Hypercuke namespace" do
      Hypercuke.topic :array do
        layer :core do
          def metasyntactic_variables ; %w[ foo bar yak shed ] ; end
        end
      end

      expect( Hypercuke::StepAdapters::Array::Core .superclass ).to be( Hypercuke::StepAdapter )
    end

    it "works when a layer name resolves to something outside the Hypercuke namespace" do
      Hypercuke.topic :absurdity do
        layer :array do
          def metasyntactic_variables ; %w[ foo bar yak shed ] ; end
        end
      end

      expect( Hypercuke::StepAdapters::Absurdity::Array .superclass ).to be( Hypercuke::StepAdapter )
    end
  end
end
