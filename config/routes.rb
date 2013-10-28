Rails.application.routes.draw do

  namespace :memory_tracker do
    get '/' => 'dashboards#index'
    match '/ca/:ca' => 'dashboards#ca', :as => 'ca', :constraints => { :ca => /.*/ }
    #resources :dashboards
  end

end
