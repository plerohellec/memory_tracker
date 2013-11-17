MemoryTracker::Engine.routes.draw do
  get '/'       => 'dashboards#index', :as => :dashboards
end
