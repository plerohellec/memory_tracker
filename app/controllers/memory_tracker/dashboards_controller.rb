class MemoryTracker::DashboardsController < ApplicationController

  layout 'memory_tracker'
  
  def index
    stats = MemoryTracker::MemoryTracker.instance.stats(:memory)
    @data = stats.to_a
    sort_by = params[:sort_by] ? params[:sort_by].to_sym : :count
    if @data.any? && @data.first.keys.include?(sort_by)
      @data = @data.sort{ |a,b| b[sort_by].to_f/b[:num] <=> a[sort_by].to_f/a[:num] }
    end

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
