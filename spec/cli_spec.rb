require 'spec_helper'

=begin

  All commands should begin with "cucumber".
  (Assume that the --require business is handled in cucumber.yml.)

  Some sample HCu commands and their expected outputs:
  $ hcu core      # cucumber --tags @core_ok
  $ hcu model     # cucumber --tags @model_ok
  $ hcu core wip  # cucumber --tags @model_wip --profile wip
  $ hcu core ok   # cucumber --tags @core_ok

  If the user specifies a --profile tag, assume they know what they're doing...
  $ hcu core --profile emperor_penguin     # cucumber --tags @core_ok --profile emperor_penguin
  $ hcu core wip --profile emperor_penguin # cucumber --tags @core_wip --profile emperor_penguin
  ...even if they use the "-p" tag instead...
  $ hcu core -p emperor_penguin     # cucumber --tags @core_ok --profile emperor_penguin
  $ hcu core wip -p emperor_penguin # cucumber --tags @core_wip --profile emperor_penguin

  Everything else should just get passed through to Cucumber unmangled.
  $ hcu core --wibble # cucumber --tags @core_ok --wibble

  Also, the '-h' flag should display HCu help (TBD)
  ( TODO: WRITE THIS EXAMPLE? )

=end

describe Hypercuke::CLI do
  let(:cmd_base) { 'cucumber' }

  def cli_for(hcu_command)
    described_class.new(hcu_command)
  end

  def expect_command_line(hcu_command, expected_output)
    argv = hcu_command.split(/\s+/)
    actual_output = cli_for(argv).cucumber_command

    expect( actual_output ).to eq( expected_output ), <<-EOF
Transforming command '#{hcu_command}':
expected: #{expected_output.inspect}
     got: #{actual_output.inspect}
    EOF
  end

  describe "cucumber command line generation" do
    it "treats the first argument as a layer name and adds the appropriate --tags flag" do
      expect_command_line 'hcu core',  "#{cmd_base} --tags @core_ok"
      expect_command_line 'hcu model', "#{cmd_base} --tags @model_ok"
    end

    it "barfs if the layer name is not given" do
      expect{ cli_for('hcu').cucumber_command }.to raise_error( "Layer name is required" )
    end

    it "ignores the 'hcu' argument in its various forms (does Ruby send this?)" do
      expect_command_line 'hcu core',     "#{cmd_base} --tags @core_ok"
      expect_command_line 'bin/hcu core', "#{cmd_base} --tags @core_ok"
    end

    it "treats the second argument as a mode -- assuming it doesn't start with a dash" do
      expect_command_line 'hcu core ok',  "#{cmd_base} --tags @core_ok"
    end

    it "adds '--profile wip' when the mode is 'wip'" do
      expect_command_line 'hcu core wip',  "#{cmd_base} --tags @core_wip --profile wip"
    end

    it "ignores most other arguments and just hands them off to Cucumber" do
      expect_command_line 'hcu core --wibble',    "#{cmd_base} --tags @core_ok --wibble"
      expect_command_line 'hcu core ok --wibble', "#{cmd_base} --tags @core_ok --wibble"
    end

    it "doesn't override a profile if the user explicitly specifies one (using either -p or --profile)" do
      expect_command_line 'hcu core --profile emperor_penguin',     "#{cmd_base} --tags @core_ok --profile emperor_penguin"
      expect_command_line 'hcu core -p emperor_penguin',            "#{cmd_base} --tags @core_ok --profile emperor_penguin"
    end

    it "doesn't override a profile if the user explicitly specifies one (using either -p or --profile), even in wip mode" do
      expect_command_line 'hcu core wip --profile emperor_penguin', "#{cmd_base} --tags @core_wip --profile emperor_penguin"
      expect_command_line 'hcu core wip -p emperor_penguin',        "#{cmd_base} --tags @core_wip --profile emperor_penguin"
    end
  end

  describe "layer_name" do
    it "matches the layer argument to 'hcu'" do
      expect( cli_for('hcu core') .layer_name ).to eq( 'core' )
      expect( cli_for('hcu model').layer_name ).to eq( 'model' )
      expect( cli_for('hcu ui')   .layer_name ).to eq( 'ui' )
    end
  end
end
