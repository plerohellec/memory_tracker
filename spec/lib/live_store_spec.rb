require 'spec_helper'

module MemoryTracker
  describe LiveStore::Manager do
    it 'should accept requests'
  end

  describe LiveStore::StatInterval do
    before :all do
      @interval = LiveStore::StatInterval.new(Time.now, 5.minutes)
      @request = MemoryTracker::Request.new({})
    end

    it 'should accept requests' do
      @interval.push(@request)
    end
  end
end