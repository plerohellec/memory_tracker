require 'spec_helper'

module MemoryTracker
  describe Request do
    before :each do
      @env = double('env')
      @request = Request.new(@env)
    end

    it 'should initalize start_gcstat' do
      @request.start_gcstat.should be_a(GcStat)
      @request.start_gcstat.keys.should include :rss
      @request.start_gcstat.keys.should include :vsize
    end

    it 'should have a controller' do
      allow(@env).to receive(:controller) { 'Foo' }
      allow(@env).to receive(:action)     { :bar }
      @request.controller.should == 'Foo'
      @request.action.should == :bar
    end

    context :close do
      it 'should initialize end_gcstat' do
        @request.close
        @request.end_gcstat.should be_a(GcStat)
      end
    end
  end
end
