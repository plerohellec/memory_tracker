module MemoryTracker

  # MemoryTracker data store
  class Data
    attr_reader :request_stats, :stats_collector
    
    def initialize
      # Per process storage
      @stats_collector = MemoryTracker::StatsCollector.new
      # Per HTTP request storage
      @request_stats = nil
    end

    def start_request(env)
      @request_stats = MemoryTracker::RequestStats.new(env)
    end

    def end_request
      return unless @request_stats
      @request_stats.close
      @stats_collector.push(@request_stats)
      @request_stats = nil
    end
    
    def accumulated_stats
      return unless @stats_collector
      @stats_collector.data
    end
  end

  # Middleware responsability is to initialize and close RequestStats
  # object at start and end of HTTP query.
  class Middleware

    def initialize(app)
      @app = app
    end

    def self.memory_tracker_data
      $memory_tracker_data
    end

    def call(env)
      self.class.memory_tracker_data.start_request(env)
      @app.call(env)
    ensure
      self.class.memory_tracker_data.end_request
    end
    
    def self.accumulated_stats
      memory_tracker_data.accumulated_stats
    end
  end  
end
