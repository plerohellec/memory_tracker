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
      request = Request.new(env)
    end
    
    def end_request(status)
      
    end
  end
  
  class Request
    attr_reader :count, :heap_count, :rss, :heap_live_num
    attr_reader :controller, :action
  end
  
  class GcStat
    def initialize(gcstat)
      @before = gcstat
      @after = GC.stat
    end
    
    def gcdiff
    end
  end
  
  class LiveStore
    def initialize(window_length)
      @window1 = Window.new(Time.now - length/2)
      @window2 = Window.new(Time.now)
    end
    
    def reset_windows
      if @window1.start_time + length > Time.now
        @window1 = @window2
        @window2 = Window.new(Time.now)
      end
    endd
        
    
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
    
    def push(request)
      @size += 1
    end
  end
    
    
end
