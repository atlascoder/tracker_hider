require_dependency 'projects_helper'

module TrackerHiderProjectSettingsPatch
  
  def self.included(base)
    
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      alias_method_chain :project_settings_tabs, :tracker_hider_settings_tab
    end
      
  end
  
  module InstanceMethods
    def project_settings_tabs_with_tracker_hider_settings_tab
      tabs = project_settings_tabs_without_tracker_hider_settings_tab
      if User.current.allowed_to?(:manage_tracker_hiders, @project) then
        tabs << {:name => 'tracker_hider', :controller => :tracker_hider, :action => :list, :partial => 'projects/tracker_hider_settings', :label => :tracker_hider_caption}
      end
      return tabs
    end
    
  end
  
end

ProjectsHelper.send(:include, TrackerHiderProjectSettingsPatch)
