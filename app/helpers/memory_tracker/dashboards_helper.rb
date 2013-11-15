module MemoryTracker
  module DashboardsHelper
    def link_to_dashboards(name)
      link_to(name, memory_tracker.dashboards_path(:sort_by => name))
    end
  end
end
