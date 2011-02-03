require 'spec_helper'

describe Rails::Sh::Command do
  before do
    Rails::Sh::Command.clear
  end

  context 'when define a command' do
    before do
      @block = lambda {}
      Rails::Sh::Command.define('foo', &@block)
    end

    it 'We can find it' do
      Rails::Sh::Command.find('foo').should eq(@block)
    end

    it 'We can find nil with wrong name' do
      Rails::Sh::Command.find('bar').should eq(nil)
    end

    it 'We can get command names' do
      Rails::Sh::Command.command_names.should =~ [:foo]
    end

    describe 'Command.[]' do
      it 'can get a command' do
        Rails::Sh::Command['foo'].should eq(@block)
      end
    end
  end

  describe '.completions' do
    context 'when command does not exist' do
      it 'completions is empty' do
        Rails::Sh::Command.completions.should be_empty
      end
    end

    context 'when commands exist' do
      before do
        Rails::Sh::Command.define('foo') {}
        Rails::Sh::Command.define('bar') {}
      end

      it 'completions is empty' do
        Rails::Sh::Command.completions.should =~ ['foo', 'bar']
      end
    end
  end

  describe '.completion_proc' do
    before do
      ['foo', 'rails generate', 'rake routes', 'rake spec'].each { |c| Rails::Sh::Command.completions << c }
    end

    it 'return completions' do
      Rails::Sh::Command.completion_proc.call('foo').should =~ ['foo']
      Rails::Sh::Command.completion_proc.call('rake').should =~ ['rake routes', 'rake spec']
    end
  end
end