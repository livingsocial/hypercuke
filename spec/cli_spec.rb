require 'spec_helper'

=begin

  All commands should begin with "cucumber --require features/hypercuke".
  This is abbreviated below as {{BASE}}.

  Some sample HCu commands and their expected outputs:
  $ hcu core      # {{BASE}} --tags @core_ok
  $ hcu model     # {{BASE}} --tags @model_ok
  $ hcu core wip  # {{BASE}} --tags @model_wip --profile wip
  $ hcu core ok   # {{BASE}} --tags @core_ok

  If the user specifies a --profile tag, assume they know what they're doing...
  $ hcu core --profile emperor_penguin     # {{BASE}} --tags @core_ok --profile emperor_penguin
  $ hcu core wip --profile emperor_penguin # {{BASE}} --tags @core_wip --profile emperor_penguin
  ...even if they use the "-p" tag instead...
  $ hcu core -p emperor_penguin     # {{BASE}} --tags @core_ok --profile emperor_penguin
  $ hcu core wip -p emperor_penguin # {{BASE}} --tags @core_wip --profile emperor_penguin

  Everything else should just get passed through to Cucumber unmangled.
  $ hcu core --wibble # {{BASE}} --tags @core_ok --wibble

  Also, the '-h' flag should display HCu help (TBD)
  ( TODO: WRITE THIS EXAMPLE? )

=end

describe Hypercuke::CLI do
  let(:cmd_base) { 'cucumber --require features/hypercuke' }

  def expect_command_line(hcu_command, expected_output)
    actual_output = subject.cucumber_command( hcu_command )
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
      expect{ subject.cucumber_command('hcu') }.to raise_error( "Layer name is required" )
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
      expect_command_line 'hcu core -p emperor_penguin',            "#{cmd_base} --tags @core_ok -p emperor_penguin"
    end

    it "doesn't override a profile if the user explicitly specifies one (using either -p or --profile), even in wip mode" do
      expect_command_line 'hcu core wip --profile emperor_penguin', "#{cmd_base} --tags @core_wip --profile emperor_penguin"
      expect_command_line 'hcu core wip -p emperor_penguin',        "#{cmd_base} --tags @core_wip -p emperor_penguin"
    end
  end
end
