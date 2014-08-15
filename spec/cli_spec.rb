require 'spec_helper'

=begin

  All commands should begin with "cucumber".
  (Assume that the --require business is handled in cucumber.yml.)

  Some sample HCu commands and their expected outputs:
  $ hcu core      # cucumber --tags @core
  $ hcu model     # cucumber --tags @model
  $ hcu core wip  # cucumber --tags @model_wip --profile wip
  $ hcu core ok   # cucumber --tags @core

  If the user specifies a --profile tag, assume they know what they're doing...
  $ hcu core --profile emperor_penguin     # cucumber --tags @core --profile emperor_penguin
  $ hcu core wip --profile emperor_penguin # cucumber --tags @core_wip --profile emperor_penguin
  ...even if they use the "-p" tag instead...
  $ hcu core -p emperor_penguin     # cucumber --tags @core --profile emperor_penguin
  $ hcu core wip -p emperor_penguin # cucumber --tags @core_wip --profile emperor_penguin

  Everything else should just get passed through to Cucumber unmangled.
  $ hcu core --wibble # cucumber --tags @core --wibble

  Also, the '-h' flag should display HCu help (TBD)
  ( TODO: WRITE THIS EXAMPLE? )

=end

describe Hypercuke::CLI do

  def cli_for(hcu_command, *args)
    described_class.new(hcu_command, *args)
  end

  describe "cucumber command line generation" do
    shared_examples_for "command line builder" do |shared_example_opts|
      let(:cmd_base) { shared_example_opts[:cmd_base] }

      def expect_command_line(hcu_command, expected_output)
        argv = hcu_command.split(/\s+/)
        actual_output = cli_for(argv).cucumber_command

        expect( actual_output ).to eq( expected_output ), <<-EOF
Transforming command '#{hcu_command}':
expected: #{expected_output.inspect}
     got: #{actual_output.inspect}
        EOF
      end

      it "ignores the 0th 'hcu' argument in its various forms (does this even happen?)" do
        expect_command_line 'hcu core',     "#{cmd_base} --tags @core --tags @core_ok"
        expect_command_line 'bin/hcu core', "#{cmd_base} --tags @core --tags @core_ok"
      end

      it "treats the first argument as a layer name and adds the appropriate --tags flag" do
        expect_command_line 'core',  "#{cmd_base} --tags @core --tags @core_ok"
        expect_command_line 'model', "#{cmd_base} --tags @model --tags @model_ok"
      end

      it "barfs if the layer name is not given" do
        expect{ cli_for('hcu').cucumber_command }.to raise_error( "Layer name is required" )
        expect{ cli_for('').cucumber_command }.to raise_error( "Layer name is required" )
      end

      it "treats the second argument as a mode (assuming it doesn't start with a dash)" do
        expect_command_line 'core ok',  "#{cmd_base} --tags @core --tags @core_ok"
      end

      it "adds '--profile wip' when the mode is 'wip'" do
        expect_command_line 'core wip',  "#{cmd_base} --tags @core_wip --profile wip"
      end

      it "ignores most other arguments and just hands them off to Cucumber" do
        expect_command_line 'core --wibble',    "#{cmd_base} --tags @core --tags @core_ok --wibble"
        expect_command_line 'core ok --wibble', "#{cmd_base} --tags @core --tags @core_ok --wibble"
      end

      it "doesn't override a profile if the user explicitly specifies one (using either -p or --profile)" do
        expect_command_line 'core --dingbat --profile emperor_penguin',     "#{cmd_base} --tags @core --tags @core_ok --profile emperor_penguin --dingbat"
        expect_command_line 'core --dingbat -p emperor_penguin',            "#{cmd_base} --tags @core --tags @core_ok --profile emperor_penguin --dingbat"
      end

      it "doesn't override a user-specified profile, even in wip mode when it would normally use the wip profile" do
        expect_command_line 'core wip --profile emperor_penguin', "#{cmd_base} --tags @core_wip --profile emperor_penguin"
        expect_command_line 'core wip -p emperor_penguin',        "#{cmd_base} --tags @core_wip --profile emperor_penguin"
      end
    end

    context "when Bundler IS NOT present" do
      before do
        allow( described_class ).to receive(:bundler_present?).and_return(false)
      end

      it_behaves_like "command line builder", cmd_base: 'cucumber'
    end

    context "when Bundler IS present" do
      before do
        allow( described_class ).to receive(:bundler_present?).and_return(true)
      end

      it_behaves_like "command line builder", cmd_base: 'bundle exec cucumber'
    end
  end

  describe "layer_name" do
    it "matches the layer argument to 'hcu'" do
      expect( cli_for('hcu core') .layer_name ).to eq( 'core' )
      expect( cli_for('hcu model').layer_name ).to eq( 'model' )
      expect( cli_for('hcu ui')   .layer_name ).to eq( 'ui' )
    end
  end

  describe "#run!" do
    let(:cli) { cli_for('fudge_ripple', output, environment, kernel) }
    let(:output) { double('output', puts: nil) }
    let(:kernel) { double('Kernel', exec: nil) }
    let(:environment) { { 'foo' => 'bar' } }

    it "prints the generated Cucumber command to output" do
      expect(output).to receive(:puts).with(cli.cucumber_command_for_display)
      cli.run!
    end

    it "uses exec to run the Cucumber command, passing in the layer name to the environment" do
      layer = Hypercuke::LAYER_NAME_ENV_VAR
      expected_env = {
        'foo' => 'bar',
        layer => 'fudge_ripple'
      }
      expect(kernel).to receive(:exec).with(expected_env, cli.cucumber_command)
      cli.run!
    end
  end
end
