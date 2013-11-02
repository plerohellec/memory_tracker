MemoryTracker::Engine.routes.draw do
  get '/' => 'dashboards#index'
  match '/ca/:ca' => 'dashboards#ca', :as => 'ca', :constraints => { :ca => /.*/ }
  #resources :dashboards
end
