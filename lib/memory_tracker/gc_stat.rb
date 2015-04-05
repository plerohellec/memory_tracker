module MemoryTracker
  class GcStat

    include Enumerable

    RUBY22_TO_CANONICAL_MAPPING = { total_allocated_objects: :total_allocated_object,
                                    total_freed_objects:     :total_freed_object,
                                    heap_allocated_pages:   :heap_used
                     }
    CANONICAL_TO_RUBY22_MAPPING = RUBY22_TO_CANONICAL_MAPPING.invert

    def initialize(rss, vsize)
      @stats = GC.stat.merge({ :rss => rss, :vsize => vsize})
    end

    def each(&block)
      @stats.each do |k, v|
        yield canonical_key_name(k), v
      end
    end

    def keys
      @stats.keys
    end

    def ordered_keys
      @stats.keys.map { |k| canonical_key_name(k) }.sort
    end

    def ordered_values(ordered_columns = ordered_keys)
      ordered_columns.inject([]) do |vals, key|
        vals << @stats[current_version_key_name(key)]
      end
    end

    def [](key)
      @stats[current_version_key_name(key)]
    end

    def canonical_key_name(key)
      self.class.canonical_key_name(key)
    end

    def current_version_key_name(key)
      self.class.current_version_key_name(key)
    end

    def self.canonical_key_name(key)
      canonical = key
      case RUBY_VERSION
      when /\A2\.2\./
        canonical = RUBY22_TO_CANONICAL_MAPPING.fetch(key, key)
      end
      canonical
    end

    def self.current_version_key_name(key)
      current_key_name = key
      case RUBY_VERSION
      when /\A2\.2\./
        current_key_name = CANONICAL_TO_RUBY22_MAPPING.fetch(key, key)
      end
      current_key_name
    end

    def self.heap_used
      GC.stat[current_version_key_name(:heap_used)]
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
      @stats = after.inject({}) do |h, (k, v)|
        h[k] = after[k] - before[k]
        h
      end
    end

    def custom
      return unless stats[:total_allocated_object] && stats[:total_freed_object]
      h = {}
      h[:total_allocated_object] = stats[:total_allocated_object]
      h[:count] = stats[:count]
      h[:rss] = stats[:rss]
      h[:heap_used] = @after[:heap_used]
      h[:in_use]    = @after[:total_allocated_object] - @after[:total_freed_object]
      h
    end
  end
end
