require 'spec_helper'

module MemoryTracker
  describe MemoryTracker do
    before :each do
      @env = double('env')
      allow(@env).to receive(:controller) { 'Boat' }
      allow(@env).to receive(:action)     { 'sail' }

      @memory_store         = double('memory_store')
      @logfile_store        = double('logfile_store')
      @tracker = MemoryTracker.instance
      @tracker.stores.clear
    end

    it 'should be a singleton' do
      lambda { MemoryTracker.new }.should raise_error(NoMethodError)
    end

    it 'should push requests to all stores' do
      allow(@memory_store).to         receive(:name) { :memory }
      allow(@logfile_store).to        receive(:name) { :gcstat_logfile }
      expect(@memory_store).to         receive(:push)
      expect(@logfile_store).to        receive(:push)

      @tracker.add_store(@memory_store)
      @tracker.add_store(@logfile_store)

      @tracker.start_request(@env)
      @tracker.end_request
    end

    it 'should populate livestore' do
      @tracker.add_store(Stores::InMemoryStore::Manager.new)

      Request.stub(:rss) { 100 }
      @tracker.start_request(@env)
      Request.stub(:rss) { 108 }
      @tracker.end_request

      stats = @tracker.stats(:memory)
      stats.count('Boat', 'sail').should == 1
      stats.count('Boat', 'moor').should == 0
      stats.fetch('Boat', 'sail', :rss).should == 8
    end
  end
end
