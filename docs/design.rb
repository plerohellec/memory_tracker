module MemoryTracker
  class Middleware
  end
  
  class MemoryTracker
    GCSTAT_LOGFILE = "#{Rails.root}/log/gcstat.log"
    
    include Singleton
    
    def initialize
      @gcstat_logger = ActiveSupport::CustomLogger.new(GCSTAT_LOGFILE)
      
    end
    
    def start_request(env)
      @request = Request.new(env)
    end
    
    def end_request(status)
      @request.close
      @gcstat_logger.info @request.logline
      LiveStoreManager.push(@request)
    end
  end
  
  class Request
    attr_reader :controller, :action
    def initialize(env)
      @start_gcstat = GcStat.new(rss, vsize)
    end
    
    def close
      @end_gcstat = GcStat.new(rss, vsize)
      @stats = GcStatIncrement.new(@start_gcstat, @end_gcstat)
    end
    
    def logline
    end
  end
  
  class GcStat
    def initialize(rss, vsize)
      @rss  = rss
      @vsize = vsize
      @stat = GC.stat
    end
  end
  
  class GcStatIncrement
    def initialize(controller, action, before, after)
    end
  end
  
  class LiveStore::Manager
    def initialize(window_length)
      @window1 = Window.new(Time.now - length/2)
      @window2 = Window.new(Time.now)
    end
    
    def reset_windows
      if @window1.start_time + length > Time.now
        @window1 = @window2
        @window2 = Window.new(Time.now)
      end
    end
        
    def push
      reset_windows
      @window1.push(request)
      @window2.push(request)
    end
    
    def stats
      @window1.stats
    end
  end
  
  class LiveStore::Window
    attr_reader :start_time, :duration, :size
    attr_accessor :data # {}
    
    def initialize
      @data = {}
    end
    
    def push(request)
      @size += 1
      @stats += request.gcstat
    end
  end
    
  class LiveStore::Stat
    def initialize
    end
    
    def <<(request)
      
  end
    
end
