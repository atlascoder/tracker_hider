require_dependency 'issue'

module TrackerHiderIssuePatch
  def self.included(base)
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    
    base.class_eval do

      alias_method :visible_without_th, :visible?
      alias_method :visible?, :visible_with_th

      class << self
        alias_method_chain :visible_condition, :tracker_hider
      end
    end
  end

  module InstanceMethods
    def visible_with_th(u=nil)
      usr = u || User.current
      users_roles = usr.members.where(project_id: project.id).collect{|m| MemberRole.find(m.id).role_id}
      hf = HiddenTracker.where("tracker_id='#{tracker.id}' AND project_id IS NULL AND user_id IS NULL AND(role_id IN (#{users_roles.join(',')}))").present?
      return (hf ? false : visible_without_th(usr))
    end
  end
  
  module ClassMethods
    
    def visible_condition_with_tracker_hider (user, *args)
      user_id = User.current.id
      visible_condition_without_tracker_hider(user, *args) +
        " AND NOT EXISTS( " +
          "SELECT * FROM hidden_trackers AS hts " + 
            " WHERE issues.tracker_id=hts.tracker_id "+
            " AND hts.project_id IS NULL "+
            " AND hts.user_id IS NULL "+
            " AND hts.role_id IS NOT NULL " +
      ## Match for selected role_id (BUT not for Anonymous and Not Member)
            " AND ((hts.role_id IN (SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
                  " WHERE m.user_id=#{user_id} AND m.project_id=issues.project_id)) " +
      ## Match for Anonymous role
            " OR (hts.role_id=2 AND 2=#{user_id})" +
      ## Match for Not Member user (Anonymous is not a member as well, yeah)
            " OR (hts.role_id=1 AND NOT EXISTS(SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
             " WHERE m.user_id=#{user_id} AND m.project_id=issues.project_id))))"
    end
    
  end
end

Issue.send(:include, TrackerHiderIssuePatch)
