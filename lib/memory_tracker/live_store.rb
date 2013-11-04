module MemoryTracker
  module LiveStore
    class Manager
      def initialize(window_length = 60*5)
        @length  = window_length
        @window1 = StatInterval.new(Time.now - @length/2, @length)
        @window2 = StatInterval.new(Time.now, @length)
      end

      def push(request)
        rotate_windows
        @window1.push(request)
        @window2.push(request)
      end

      def stats
        rotate_windows
        @window1.stats
      end

      private
      def rotate_windows
        if Time.now > @window1.start_time + @length
          @window1 = @window2
          @window2 = StatInterval.new(Time.now, @length)
        end
      end
    end

    class StatInterval
      attr_reader :start_time, :duration, :size, :stats

      extend Forwardable
      def_delegators :@stats, :fetch, :each

      include Enumerable

      def initialize(start_time, duration_seconds)
        @start_time = start_time
        @duration   = duration_seconds
        @size       = 0
        @stats = Stats.new
      end

      def push(request)
        @size += 1
        delta = request.gcstat_delta.stats
        delta.each_key do |key|
          @stats.increment_action_counter(request.controller, request.action, key, delta[key])
        end
      end
    end

    class Stats
      def initialize
        @data = {}
      end

      def fetch(controller, action, key)
        if @data[controller]
          if @data[controller][action]
            if @data[controller][action][key]
              return @data[controller][action][key]
            end
          end
        end
        0
      end

      def each(&block)
        @data.each do |controller, h|
          h.each do |action, stats|
            yield [controller, action, stats]
          end
        end
      end

      def increment_action_counter(controller, action, key, value)
        if @data[controller]
          if @data[controller][action]
            if @data[controller][action][key]
              @data[controller][action][key] += value
            else
              @data[controller][action][key] = value
            end
          else
            @data[controller][action] = { key => value }
          end
        else
          @data[controller] = { action => { key => value } }
        end
      end
    end
  end
end
