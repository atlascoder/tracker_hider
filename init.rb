require_dependency 'tracker_hider_issue_patch'
require_dependency 'tracker_hider_project_settings_patch'
require_dependency 'tracker_hider_project_patch'

Redmine::Plugin.register :tracker_hider do
  name 'Tracker Hider plugin for Redmine'
  author 'Anton Titkov'
  description 'The plugin allows to hide specified tracker for cpecified users within a project'
  version '0.1.0'
  url 'https://github.com/atlascoder/tracker_hider'
  author_url 'https://github.com/atlascoder'
  
  project_module :tracker_hider do
    permission :manage_tracker_hiders, {:tracker_hider => [:add_hider, :remove]}
  end
end
