require 'spec_helper'

describe Rails::Sh do
  context 'when define a command' do
    before do
      @block = lambda {}
      Rails::Sh::Command.define('foo', &@block)
    end

    ['foo'].each do |line|
      it "the command should be executed if the line is '#{line}'" do
        @block.should_receive(:call).with(nil).once
        Rails::Sh.should_receive(:execute_rails_command).with(line).exactly(0).times
        Rails::Sh.execute(line)
      end
    end

    ['fo', 'bar'].each do |line|
      it "the command should not be executed if the line is '#{line}'" do
        @block.should_receive(:call).with(nil).exactly(0).times
        Rails::Sh.should_receive(:execute_rails_command).with(line).once
        Rails::Sh.execute(line)
      end
    end
  end

  ['console', 'g --help'].each do |line|
    it "a rails's command should be executed if the line is #{line}" do
      Rails::Sh.should_receive(:load).with("rails/commands.rb") do
        ARGV.should eq(line.split(/\s+/))
      end
      Rails::Sh.execute(line)
    end
  end
end