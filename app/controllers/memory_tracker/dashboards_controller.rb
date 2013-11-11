class MemoryTracker::DashboardsController < ApplicationController

  layout 'memory_tracker'
  
  def index
    @data = MemoryTracker::MemoryTracker.instance.stats(:live)
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
