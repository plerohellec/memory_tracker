module MemoryTracker
  class MemoryTracker
    include Singleton
    include Sys

    attr_reader   :request_stats, :livestore, :logger
    attr_accessor :gcstat_logger

    def initialize
      # Per process storage
      @livestore = LiveStore::Manager.new
      # Per HTTP request storage
      @request = nil
      @logger = ::MemoryTracker::Logger.instance
    end

    def start_request(env)
      @request = Request.new(env)
    end

    def end_request
      return unless @request
      @request.close
      @livestore.push(@request)

      @logger.log(@request)
      gcstat_logger.info @request.end_gcstat.logline

      @request = nil
    end

    def live_stats
      return unless @livestore
      @livestore.stats
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
