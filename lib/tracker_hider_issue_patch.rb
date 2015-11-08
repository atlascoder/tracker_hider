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
      user_id = user.id || 'NULL'
      visible_condition_without_tracker_hider(user, *args) +
        " AND NOT EXISTS( "+
          "SELECT * from hidden_trackers WHERE (" + 
      ## Match for selected user_id
              "((hidden_trackers.project_id IN (SELECT project_id FROM enabled_modules WHERE enabled_modules.name='tracker_hider'))" +
              " AND issues.tracker_id=tracker_id" +
              " AND issues.project_id=project_id" +
              " AND user_id=#{user_id})" +
      ## Match for selected role_id (BUT not for Anonymous and Not Member)
            " OR " +
              "((hidden_trackers.project_id IN (SELECT project_id FROM enabled_modules WHERE enabled_modules.name='tracker_hider'))" +
              " AND issues.tracker_id=tracker_id" +
              " AND issues.project_id=project_id" +
              " AND (hidden_trackers.role_id IN (SELECT role_id FROM member_roles WHERE member_id IN ("+
                "SELECT id from members WHERE user_id=#{user_id} AND project_id=hidden_trackers.project_id" +
              "))))" +
      ## Match for Anonymous user
            " OR " +
              "((hidden_trackers.project_id IN (SELECT project_id FROM enabled_modules WHERE enabled_modules.name='tracker_hider'))" +
              " AND issues.tracker_id=tracker_id" +
              " AND issues.project_id=project_id" +
              " AND hidden_trackers.role_id='2' AND '#{user_id}'='2')" +
      ## Match for Not Member user
            " OR " +
              "((hidden_trackers.project_id IN (SELECT project_id FROM enabled_modules WHERE enabled_modules.name='tracker_hider'))" +
              " AND issues.project_id=project_id" +
              " AND issues.project_id=project_id" +
              " AND issues.tracker_id=tracker_id" +
              " AND (hidden_trackers.role_id='1' AND NOT EXISTS(SELECT m.id FROM members as m INNER JOIN member_roles as mr ON m.id=mr.member_id WHERE m.project_id=hidden_trackers.project_id AND m.user_id='#{user_id}')))" +
          ")" +
        ")"
    end
    
  end
end

Issue.send(:include, TrackerHiderIssuePatch)
