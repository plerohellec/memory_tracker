module MemoryTracker
  module DashboardsHelper
    def link_to_dashboards(name)
      link_to(name, memory_tracker.dashboards_path(:sort_by => name))
    end

    def display_num(val, num)
      f = val.to_f / num
      if f > 1000
        f.to_i
      else
        '%.3f' % (val.to_f/num)
      end
    end
  end
end
