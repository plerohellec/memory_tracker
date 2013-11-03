require 'spec_helper'

module MemoryTracker
  describe LiveStore::Manager do
    it 'should accept requests'
  end

  describe LiveStore::StatInterval do
    before :all do
      @interval = LiveStore::StatInterval.new(Time.now, 5*60)
      @request = MemoryTracker::Request.new({})
    end

    it 'should accept requests' do
      @request.stub(:request).and_return({ :controller => 'Foo', :action => :bar})
      @request.close
      @interval.push(@request)
    end
  end
end