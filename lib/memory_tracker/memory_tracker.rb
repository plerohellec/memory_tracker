module MemoryTracker
  class MemoryTracker
    include Singleton
    include Sys

    attr_reader :request_stats, :livestore, :logger

    GCSTAT_LOGFILE = "#{Rails.root}/log/gcstat.log"

    def initialize
      # Per process storage
      @livestore = LiveStore::Manager.new
      # Per HTTP request storage
      @request = nil
      @logger = ::MemoryTracker::Logger.instance
      @gcstat_logger = ActiveSupport::CustomLogger.new(GCSTAT_LOGFILE)
    end

    def start_request(env)
      @request = Request.new(env)
    end

    def end_request(status=nil)
      return unless @request
      @request.close
      @livestore.push(@request)

      @logger.log(@request)
      @gcstat_logger.info @request.end_gcstat.logline

      @request = nil
    end

    def live_stats
      return unless @livestore
      @livestore.stats
    end

    def self.track_block(name, &block)
      raise ArgumentError unless block_given?
      before = GC.stat
      ret = yield
      after = GC.stat
      Rails.logger.debug "gcstat diff for #{name}: #{GcStat.gcdiff(before, after)}"
      ret
    end

    private

  end
end
