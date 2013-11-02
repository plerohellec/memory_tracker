class MemoryTracker::DashboardsController < ApplicationController

  layout 'memory_tracker'
  
  def index
    respond_to do |format|
      format.json do
        render :json => MemoryTracker::MemoryTracker.instance.accumulated_stats.to_json
      end
      format.html do
        @data = MemoryTracker::MemoryTracker.instance.accumulated_stats
        @sorted_cas = @data
        render
      end
    end
  end


  def ca
    ca = params[:ca]
    @data = MemoryTracker::MemoryTracker.instance.accumulated_stats
    @num = @data[ca][:num]
  end
end
