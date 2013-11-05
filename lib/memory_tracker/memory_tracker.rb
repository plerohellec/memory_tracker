module MemoryTracker
  class MemoryTracker
    include Singleton
    include Sys

    attr_accessor :gcstat_logger, :store

    def start_request(env)
      @request = Request.new(env)
    end

    def end_request
      return unless @request
      @request.close
      store.push(@request)

      gcstat_logger.info @request.end_gcstat.logline

      @request = nil
    end

    def stats
      return unless store
      store.stats
    end

    def self.track_block(*args)
      self.instance.track_block(*args)
    end

    def track_block(name, &block)
      raise ArgumentError unless block_given?
      before = GC.stat
      ret = yield
      after = GC.stat
      gcstat_logger.debug "gcstat diff for #{name}: #{GcStat.gcdiff(before, after)}"
      ret
    end

    private

  end
end
