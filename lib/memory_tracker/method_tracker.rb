module MemoryTracker
  module MethodTracker
    def self.track_memory(name, &block)
      before = GC.stat
      ret = yield
      after = GC.stat
      Rails.logger.debug "gcstat diff for #{name}: #{GcStat.gcdiff(before, after)}"
      ret
    end
  end
end
