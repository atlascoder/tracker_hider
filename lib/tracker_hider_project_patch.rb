require_dependency 'project'

module TrackerHiderProjectPatch
  
  def self.included(base)
    
    base.class_eval do
      has_many :hidden_trackers
      has_and_belongs_to_many :trackers
      
      def rolled_up_trackers
        trackers
      end
      
      def trackers
        user_id = User.current.id || 2
        super.where(
          "NOT EXISTS( " +
            "SELECT * FROM hidden_trackers AS hts " + 
              " WHERE trackers.id=hts.tracker_id "+
              " AND hts.project_id IS NULL "+
              " AND hts.user_id IS NULL "+
              " AND hts.role_id IS NOT NULL " +
        ## Match for selected role_id (BUT not for Anonymous and Not Member)
              " AND ((hts.role_id IN (SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
                    " WHERE m.user_id=#{user_id} AND m.project_id=#{id})) " +
        ## Match for Anonymous role
              " OR (hts.role_id=2 AND 2=#{user_id})" +
        ## Match for Not Member user (Anonymous isn't a member as well, yeah)
              " OR (hts.role_id=1 AND NOT EXISTS(SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
               " WHERE m.user_id=#{user_id} AND m.project_id=#{id}))))"
        ).order(:position)
      end
      
        
    end
  end
  
end

Project.send(:include, TrackerHiderProjectPatch)
