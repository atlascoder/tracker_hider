require_dependency 'issue'

module TrackerHiderIssuePatch
  def self.included(base)
    
    base.extend(ClassMethods)
    
    base.class_eval do
      class << self
        alias_method_chain :visible_condition, :tracker_hider
      end
    end
  end
  
  module ClassMethods
    
    def visible_condition_with_tracker_hider (user, *args)
      visible_condition_without_tracker_hider(user, *args) + " AND (tracker_id NOT IN (SELECT tracker_id from hidden_trackers WHERE project_id=issues.project_id AND user_id=#{user.id}))"
    end
    
  end
end

Issue.send(:include, TrackerHiderIssuePatch)
