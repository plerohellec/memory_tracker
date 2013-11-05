require 'spec_helper'

module MemoryTracker
  describe MemoryTracker do
    before :each do
      @env = double('env')
      allow(@env).to receive(:controller)
      allow(@env).to receive(:action)
    end

    it 'should be a singleton' do
      lambda { MemoryTracker.new }.should raise_error(NoMethodError)
    end

    it 'should log gcstat to gcstat_logger' do
      tracker = MemoryTracker.instance
      gcstat_logger = double('gcstat_logger')
      tracker.gcstat_logger = gcstat_logger
      expect(gcstat_logger).to receive(:info)

      tracker.start_request(@env)
      tracker.end_request
    end

    it 'should populate livestore' do
    end
  end
end
