require_dependency "memory_tracker/application_controller"

module MemoryTracker
  class DashboardsController < ApplicationController

    layout 'memory_tracker'

    def index
      stats = MemoryTracker.instance.stats(:memory)
      @data = stats.to_a
      sort_by = params[:sort_by] ? params[:sort_by].to_sym : :count
      if @data.any? && @data.first.keys.include?(sort_by)
        if sort_by == :num
          @data = @data.sort { |a,b| b[sort_by] <=> a[sort_by] }
        else
          @data = @data.sort{ |a,b| b[sort_by].to_f/b[:num] <=> a[sort_by].to_f/a[:num] }
        end
      end

      @pid = Process.pid
      @rss = Request.rss
      @vsize = Request.vsize
      @num_heaps = GC.stat[:heap_used]

      respond_to do |format|
        format.json do
          render :json => @data.to_json
        end
        format.html do
          render
        end
      end
    end
  end
end
