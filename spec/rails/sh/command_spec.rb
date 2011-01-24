require 'spec_helper'

describe Rails::Sh::Command do
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
      Rails::Sh::Command.command_names.should =~ [:exit, :foo, :routes]
    end
  end
end