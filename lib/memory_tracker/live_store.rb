module MemoryTracker
  module LiveStore
    class Manager
      def initialize(window_length = 60*5)
        @length  = window_length
        @window1 = StatInterval.new(Time.now - @length/2, @length)
        @window2 = StatInterval.new(Time.now, @length)
      end

      def rotate_windows
        if @window1.start_time + length > Time.now
          @window1 = @window2
          @window2 = StatInterval.new(Time.now, @length)
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

    class StatInterval
      attr_reader :start_time, :duration, :size
      attr_reader :data

      def initialize(start_time, duration_seconds)
        @start_time = start_time
        @duration   = duration_seconds
        @size       = 0
        @data = {}
      end

      def push(request)
        @size += 1
        delta = request.gcstat_delta.stat
        delta.each do |key|
          increment_action_counter(request.controller, request.action, key, delta[key])
        end
      end

      private
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
