# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

  get "/tracker_hider_settings", :to => "tracker_hider#settings", :as => 'tracker_hider_settings'
  post "/add_tracker_hider_global_rule", :to => "tracker_hider#add_global_rule", :as => 'add_tracker_hider_global_rule'
  delete "/drop_tracker_hider_global_rule", :to => "tracker_hider#drop_global_rule", :as => 'drop_tracker_hider_global_rule'
