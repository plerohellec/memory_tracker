module MemoryTracker
  module GcStat
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
end
