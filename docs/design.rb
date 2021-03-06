module MemoryTracker
  class Middleware
  end
  
  class Engine
    def initialize_stores
      MemoryTracker.instance.add_store(InMemoryStore.new)
      MemoryTracker.instance.add_store(LogfileStore.new)
    end
  end
  
  class MemoryTracker
    GCSTAT_LOGFILE = "#{Rails.root}/log/gcstat.log"
    
    include Singleton
    
    def stores
      @stores ||= {}
    end
    
    def add_stores
    end
    
    def start_request(env)
      @request = Request.new(env)
    end
    
    def end_request(status)
      @request.close
      stores.each { |store| store.push(@request) }
    end
  end
  
  class Request
    attr_reader :controller, :action, :gcstat_delta
    def initialize(env)
      @start_gcstat = GcStat.new(rss, vsize)
    end
    
    def close
      @end_gcstat = GcStat.new(rss, vsize)
      @gcstat_delta = GcStatDelta.new(@start_gcstat, @end_gcstat)
    end
  end
  
  class GcStat
    attr_reader :stat
    def initialize(rss, vsize)
      @stat = GC.stat.merge({ :rss => rss, :vsize => vsize})
    end
  end
  
  class GcStatDelta
    def initialize(before, after)
      @stat = after.inject({}) do |h, (k, v)|
        h[k] = after[k] - before [k]
        h
      end
    end
  end
  
  module Stores
    class InMemoryStore::Manager
      def initialize(window_length)
        @window1 = StatInterval.new(Time.now - length/2)
        @window2 = StatInterval.new(Time.now)
      end

      def name
        :memory
      end

      def rotate_windows
        if @window1.start_time + length > Time.now
          @window1 = @window2
          @window2 = Window.new(Time.now)
        end
      end

      def push
        rotate_windows
        @window1.push(request)
        @window2.push(request)
      end

      def stats
        @window1.stats
      end
    end

    class InMemoryStore::StatInterval
      attr_reader :start_time, :duration, :size
      attr_accessor :data # {}

      def initialize
        @data = {}
      end

      def push(request)
        @size += 1
        delta = request.gcstat_delta
        delta.each do |key|
          increment_action_counter(request.controller, request.action, key, delta[key])
        end
      end

      def increment_action_counter(controller, action, key, value)
      end
    end
  end
end
