module MemoryTracker

  # MemoryTracker data store
  class Data
    include Singleton
    attr_reader :request_stats, :stats_collector, :logger
    
    def initialize
      # Per process storage
      @stats_collector = MemoryTracker::StatsCollector.new
      # Per HTTP request storage
      @request_stats = nil
      @logger = Logger.instance
    end

    def start_request(env)
      @request_stats = MemoryTracker::RequestStats.new(env)
    end

    def end_request(status)
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
  end

  class Logger
    include Sys
    include Singleton
    attr_reader :memory_logfile, :memory_log, :last_rss, :last_gcstats

    def initialize
      @memory_logfile = File.open(Rails.root.join("log", MEMORY_LOG), 'a')
      @memory_log = ActiveSupport::BufferedLogger.new(memory_logfile)
      @memory_log.level = ActiveSupport::BufferedLogger::INFO

      @last_rss = 0.0
      @last_gcstats = {}
    end

    def log(request)
      pid = Process.pid
      rss = ProcTable.ps(pid).rss * 0.004096
      vsize = ProcTable.ps(pid).vsize * 0.000001
      gcstats = GC.stat

      log_msg = "#{Time.now.localtime.strftime("%m-%d %H:%M:%S")} pid:#{'%05d' % pid} #{request.status}"
      log_msg << " rss=#{'%6.2f' % rss}"
      log_msg << " vsize=#{'%6.2f' % vsize}"

      if (rss / @last_rss > 1.005) || gcstats[:heap_used] - @last_gcstats[:heap_used] > 0
        log_msg << " *** #{MemoryTracker::GcStat.gcdiff(@last_gcstats, gcstats).inspect}"
      end

      log_msg << " #{request.path}"

      @memory_log.info log_msg
      @memory_logfile.flush
      @last_rss = rss
      @last_gcstats = gcstats
    end
  end


  # Middleware responsability is to initialize and close RequestStats
  # object at start and end of HTTP query.
  class Middleware

    def initialize(app)
      @app = app
    end

    def self.memory_tracker_data
      MemoryTracker::Data.instance
    end

    def call(env)
      self.class.memory_tracker_data.start_request(env)
      status, headers, body = @app.call(env)
    ensure
      self.class.memory_tracker_data.end_request(status)
    end
    
    def self.accumulated_stats
      memory_tracker_data.accumulated_stats
    end
  end  
end
