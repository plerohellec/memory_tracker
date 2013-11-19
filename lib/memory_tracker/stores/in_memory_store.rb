module MemoryTracker
  module Stores
    module InMemoryStore
      class Manager < Base
        register_store :memory

        def initialize(opts = {})
          @length  = opts.fetch(:window_length, 60*60*4)

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
          ca = controller_action_data(controller, action)
          ca[:gcstat][attr]
        end

        def count(controller, action)
          ca = controller_action_data(controller, action)
          ca[:num]
        end

        def each(&block)
          @data.each do |controller, h|
            h.each do |action, stats|
              yield [controller, action, stats]
            end
          end
        end

        def increment_action_count(controller, action)
          ca = controller_action_data(controller, action)
          ca[:num] += 1
        end

        def increment_action_attribute(controller, action, attr, value)
          ca = controller_action_data(controller, action)
          if ca[:gcstat][attr]
            ca[:gcstat][attr] += value
          else
            ca[:gcstat][attr] = value
          end
        end


        def to_a
          a = []
          @data.each do |controller, actions|
            actions.each do |action, counters|
              row = { :controller => controller, :action => action, :num => counters[:num] }
              row.merge!(counters[:gcstat])
              a << row
            end
          end
          a
        end

        private

        def controller_action_data(controller, action)
          @data[controller] = { action => { :num => 0, :gcstat => {} } } unless @data[controller]
          @data[controller][action] = { :num => 0, :gcstat => {} }       unless @data[controller][action]
          @data[controller][action]
        end
      end
    end
  end
end
