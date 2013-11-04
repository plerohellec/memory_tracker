require 'spec_helper'

module MemoryTracker
  describe MemoryTracker do
    it 'should be a singleton' do
      lambda { MemoryTracker.new }.should raise_error(NoMethodError)
    end

    it 'should log gcstat to gcstat_logger'
    it 'should populate livestore'
  end
end
