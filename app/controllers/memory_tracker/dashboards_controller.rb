class MemoryTracker::DashboardsController < ApplicationController

  layout 'memory_tracker'
  
  def index
    respond_to do |format|
      format.json do
        render :json => MemoryTracker::MemoryTracker.instance.live_stats.to_json
      end
      format.html do
        @data = MemoryTracker::MemoryTracker.instance.live_stats
        @sorted_cas = @data
        render
      end
    end
  end


  def ca
    ca = params[:ca]
    @data = MemoryTracker::MemoryTracker.instance.live_stats
    @num = @data[ca][:num]
  end
end
