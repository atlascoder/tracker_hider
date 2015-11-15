require_dependency 'tracker_hider_issue_patch'
require_dependency 'tracker_hider_project_patch'

Redmine::Plugin.register :tracker_hider do
  name 'Tracker Hider plugin for Redmine'
  author 'Anton Titkov'
  description 'The plugin allows to hide specified tracker for specified roles globally'
  version '0.2.0'
  url 'https://github.com/atlascoder/tracker_hider'
  author_url 'https://github.com/atlascoder'

  menu :admin_menu, :trackers_visibility, {:controller => 'tracker_hider', :action => 'settings'}, :caption => :label_tracker_hider
  
end
