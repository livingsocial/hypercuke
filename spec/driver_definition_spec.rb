require 'spec_helper'

describe "driver definition API" do
  subject { Hypercuke }

  # NAMING THINGS
  #
  # Area of domain: Topic
  # Layer of application: Layer
  # Intersection of the two:  Step Driver
  # Name of generated step driver: Hypercuke::StepDrivers::<Topic>::<Layer>
  #
  #     L               T O P I C S
  #     A |       | Cheese     | Wine | Bread |
  #     Y | Core  | SD*        | SD*  | SD*   |
  #     E | Model | SD*        | SD*  | SD*   |
  #     R | UI    | SD*        | SD*  | SD*   |
  #     S
  #           * SD = StepDriver

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
    it "has no step drivers when it starts" do
      expect( subject::StepDrivers.constants ).to be_empty
    end
  end

  context "with a single driver in a single layer" do
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

    let(:sd_class) { subject.step_driver_class( :cheese, :core ) }

    it "defines a cheese topic" do
      expect( subject.topics ).to eq( [:cheese] )
    end

    it "defines a core layer" do
      expect( subject.layers ).to eq( [:core] )
    end

    it "defines a step driver class for the cheese/core combo" do
      expect( sd_class ).to_not be_nil
      expect( sd_class.superclass ).to be( Hypercuke::StepDriver )
      expect( sd_class.instance_methods(false) ).to eq( [ :select_variety ] )
    end

    it "allows the step driver to be reopened" do
      subject.topic :cheese do
        layer :core do
          def pair_with(wine)
            "I probably should pick an example I know more about"
          end
        end
      end

      expect( sd_class.instance_methods(false).sort ).to eq( [ :select_variety, :pair_with ].sort )
    end

    it "gives the step driver class a reasonable name" do
      expect( sd_class.name ).to eq( "Hypercuke::StepDrivers::Cheese::Core" )
    end
  end

  context "with two drivers and three layers" do
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

    it "defines step driver classes with reasonable class names" do
      expect( Hypercuke::StepDrivers::Wibble::Spam .superclass ).to be( Hypercuke::StepDriver )
      expect( Hypercuke::StepDrivers::Wibble::Eggs .superclass ).to be( Hypercuke::StepDriver )
      expect( Hypercuke::StepDrivers::Wibble::Bacon.superclass ).to be( Hypercuke::StepDriver )

      expect( Hypercuke::StepDrivers::Yak::Spam .superclass ).to be( Hypercuke::StepDriver )
      expect( Hypercuke::StepDrivers::Yak::Eggs .superclass ).to be( Hypercuke::StepDriver )
      expect{ Hypercuke::StepDrivers::Yak::Bacon }.to raise_error(NameError)
    end

    describe "step driver instantiation" do
      it "can create a step driver that was defined" do
        driver_klass = Hypercuke.step_driver_class( :wibble, :spam )
        expect( driver_klass ).to be Hypercuke::StepDrivers::Wibble::Spam
        driver = driver_klass.new
        expect( driver.wibble ).to eq("wibble spam")
      end

      it "explodes when asked for a step driver that was not defined" do
        expect { Hypercuke.step_driver_class( :yak, :bacon ) }.to raise_error( NameError )
      end
    end
  end
end
