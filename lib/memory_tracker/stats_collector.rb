module MemoryTracker
  class StatsCollector
    def initialize
      @stats = {}
    end

    def push(request)
      ca = controller_action_string(request)
      add_request(ca)
    end

    def log
      pp @stats
    end

    def data
      @stats
    end

   private
    def add_request(ca, operations, tables)
      if @stats[ca]
        @stats[ca][:num] += 1
      else
        @stats[ca] = { :num => 1 }
      end
    end

    def increment_item(hash, item, val)
      if hash[item]
        hash[item] += val
      else
        hash[item] = val
      end
    end

    def controller_action_string(request)
      "#{request.controller_name}/#{request.action_name}"
    end
  end
end
