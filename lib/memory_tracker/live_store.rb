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
        @stats.increment_action_count(request.controller, request.action)
        delta.each_key do |attr|
          @stats.increment_action_attribute(request.controller, request.action, attr, delta[attr])
        end
      end
    end

    class Stats
      def initialize
        @data = {}
      end

      def fetch(controller, action, attr)
        if @data[controller]
          if @data[controller][action]
            if @data[controller][action][:gcstat][attr]
              return @data[controller][action][:gcstat][attr]
            end
          end
        end
      end

      def count(controller, action)
        if @data[controller]
          if @data[controller][action]
            return @data[controller][action][:num]
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

      def increment_action_count(controller, action)
        if @data[controller]
          if @data[controller][action]
            if @data[controller][action][:num]
              @data[controller][action][:num] += 1
            else
              @data[controller][action][:num] = 1
            end
          else
            @data[controller][action] = { :num => 1}
          end
        else
          @data[controller] = { action => { :num => 1} }
        end
      end

      def increment_action_attribute(controller, action, attr, value)
        if @data[controller]
          if @data[controller][action]
            if @data[controller][action][:gcstat]
              if @data[controller][action][:gcstat][attr]
                @data[controller][action][:gcstat][attr] += value
              else
                @data[controller][action][:gcstat][attr] = value
              end
            else
              @data[controller][action][:gcstat]  = { attr => value }
            end
          else
            @data[controller][action] = { :gcstat => { attr => value } }
          end
        else
          @data[controller] = { action => { :gcstat => { attr => value } } }
        end
      end


    end
  end
end
