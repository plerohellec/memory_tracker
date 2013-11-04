require 'spec_helper'

module MemoryTracker
  describe Request do
    before :all do
      @request = Request.new({})
    end

    it 'should initalize start_gcstat' do
      @request.start_gcstat.should be_a(GcStat)
      @request.start_gcstat.stats.keys.should include :rss
      @request.start_gcstat.stats.keys.should include :vsize
    end

    it 'should have a controller' do
      @request.stub(:request).and_return({ :controller => 'Foo', :action => :bar})
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
