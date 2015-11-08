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
        " AND (EXISTS(SELECT id FROM enabled_modules AS em WHERE em.project_id=issues.project_id AND em.name='tracker_hider') AND NOT EXISTS( " +
          "SELECT * from hidden_trackers AS hts WHERE issues.tracker_id=hts.tracker_id AND issues.project_id=hts.project_id " +
              " AND (" + 
      ## Match for selected user_id
                  " hts.user_id=#{user_id} " +
      ## Match for selected role_id (BUT not for Anonymous and Not Member)
                " OR ((hts.role_id IS NOT NULL) AND hts.role_id IN (SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
                  " WHERE m.user_id=#{user_id} AND m.project_id=issues.project_id)) " +
      ## Match for Anonymous user
                " OR (hts.role_id=2 AND 2=#{user_id})" +
      ## Match for Not Member user (Anonymous isn't a member as well, yeah)
                " OR ((hts.role_id=1) AND NOT EXISTS(SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
                  " WHERE m.user_id=#{user_id} AND m.project_id=issues.project_id)) " +
              ")" +
          ")" +
        ")"
    end
    
  end
end

Issue.send(:include, TrackerHiderIssuePatch)
