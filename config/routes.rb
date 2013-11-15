MemoryTracker::Engine.routes.draw do
  get '/'       => 'memory_tracker/dashboards#index', :as => :dashboards
end
