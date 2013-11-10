require 'spec_helper'

module MemoryTracker
  describe MemoryTracker do
    before :each do
      @env = double('env')
      allow(@env).to receive(:controller) { 'Boat' }
      allow(@env).to receive(:action)     { 'sail' }

      @gcstat_logger = double('gcstat_logger')
      @store         = double('store')
      @tracker = MemoryTracker.instance
    end

    it 'should be a singleton' do
      lambda { MemoryTracker.new }.should raise_error(NoMethodError)
    end

    it 'should log gcstat to gcstat_logger' do
      @tracker.gcstat_logger = @gcstat_logger
      @tracker.stores[:live] = @store
      expect(@gcstat_logger).to receive(:info)
      expect(@store).to          receive(:push)

      @tracker.start_request(@env)
      @tracker.end_request
    end

    it 'should populate livestore' do
      @tracker.gcstat_logger = @gcstat_logger
      @tracker.stores[:live] = LiveStore::Manager.new
      allow(@gcstat_logger).to receive(:info)

      Request.stub(:rss) { 100 }
      @tracker.start_request(@env)
      Request.stub(:rss) { 108 }
      @tracker.end_request

      stats = @tracker.stats(:live)
      stats.count('Boat', 'sail').should == 1
      stats.count('Boat', 'moor').should == 0
      stats.fetch('Boat', 'sail', :rss).should == 8
    end
  end
end
