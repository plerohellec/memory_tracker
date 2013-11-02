MemoryTracker::Engine.routes.draw do
  get '/'       => 'dashboards#index'
  get '/ca/:ca' => 'dashboards#ca', :as => 'memory_tracker_ca', :constraints => { :ca => /.*/ }
  #resources :dashboards
end
