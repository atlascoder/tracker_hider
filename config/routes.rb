# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

  get ":project_id/list_tracker_hiders", :to => "tracker_hider#list", :as => 'list_tracker_hider'
  post ":project_id/add_tracker_hider", :to => "tracker_hider#add_hider", :as => 'add_tracker_hider'
  delete ":project_id/delete_tracker_hider/:id", :to => "tracker_hider#remove", :as => 'delete_tracker_hider'
