module MemoryTracker
  class MemoryTracker
    include Singleton
    attr_reader :request_stats, :stats_collector, :logger

    def initialize
      # Per process storage
      @stats_collector = StatsCollector.new
      # Per HTTP request storage
      @request_stats = nil
      @logger = ::MemoryTracker::Logger.instance
    end

    def start_request(env)
      @request_stats = RequestStats.new(env)
    end

    def end_request(status=nil)
      return unless @request_stats
      @request_stats.status = status
      @request_stats.close
      @stats_collector.push(@request_stats)
      @logger.log(@request_stats)
      @request_stats = nil
    end

    def accumulated_stats
      return unless @stats_collector
      @stats_collector.data
    end

    def self.track_block(name, &block)
      raise ArgumentError unless block_given?
      before = GC.stat
      ret = yield
      after = GC.stat
      @logger.log "gcstat diff for #{name}: #{GcStat.gcdiff(before, after)}"
      ret
    end
  end
end
