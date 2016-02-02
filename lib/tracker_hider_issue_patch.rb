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
      if project.enabled_modules.collect{|pm| pm.name}.include? 'tracker_hider' then
        usr = u || User.current
        users_roles = usr.members.where(project_id: project.id).collect{|m| MemberRole.where(member_id: m.id).first.role_id}

	if(users_roles.length > 0) then
		roles_check_clause = "(role_id IN (#{users_roles.join(',')}))"
	else
		roles_check_clause = "FALSE"
	end

        hf = HiddenTracker.where("tracker_id='#{tracker.id}' AND project_id='#{project.id}' AND ((user_id='#{usr.id}') OR #{roles_check_clause})").present?
        return (hf ? false : visible_without_th(usr))
      else
        return visible_without_th(usr)
      end  
    end
  end
  
  module ClassMethods
    
    def visible_condition_with_tracker_hider (user, *args)
      user_id = user.id || 2
      visible_condition_without_tracker_hider(user, *args) +
        " AND (NOT EXISTS( " +
          "SELECT * FROM hidden_trackers AS hts INNER JOIN enabled_modules AS em ON hts.project_id=em.project_id WHERE issues.tracker_id=hts.tracker_id AND issues.project_id=hts.project_id " +
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
