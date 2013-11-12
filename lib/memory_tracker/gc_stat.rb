module MemoryTracker
  class GcStat
    attr_reader :stats

    def initialize(rss, vsize)
      @stats = GC.stat.merge({ :rss => rss, :vsize => vsize})
    end

    def ordered_keys
      @stats.keys.sort
    end

    def ordered_values
      ordered_keys.inject([]) do |vals, key|
        vals << @stats[key]
        vals
      end
    end

    def self.gcdiff(before, after)
      return {} unless (before && before[:total_allocated_object] && before[:total_freed_object])
      return {} unless (after && after[:total_allocated_object] && after[:total_freed_object])
      diff = {}
      b = before.clone
      a = after.clone
      diff[:num_alloc] = a[:total_allocated_object] - b[:total_allocated_object]
      diff[:num_heaps] = a[:heap_used]
      [ a, b ].each do |x|
        x.delete(:heap_increment)
        x.delete(:heap_length)
        x.delete(:heap_final_num)
        x[:in_use] = x.delete(:total_allocated_object) - x.delete(:total_freed_object)
      end
      b.each_key do |key|
        diff[key] = a[key] - b[key]
      end
      diff
    end
  end

  class GcStatDelta
    attr_reader :stats

    def initialize(before, after)
      @after = after
      @stats = after.stats.inject({}) do |h, (k, v)|
        h[k] = after.stats[k] - before.stats[k]
        h
      end
    end

    def custom
      return unless stats[:total_allocated_object] && stats[:total_freed_object]
      h = {}
      h[:total_allocated_object] = stats[:total_allocated_object]
      h[:count] = stats[:count]
      h[:rss] = stats[:rss]
      h[:heap_used] = @after.stats[:heap_used]
      h[:in_use]    = @after.stats[:total_allocated_object] - @after.stats[:total_freed_object]
      h
    end
  end
end
