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
        super.where(
          "NOT EXISTS( " +
            "SELECT * FROM hidden_trackers AS hts INNER JOIN enabled_modules AS em ON hts.project_id=em.project_id WHERE hts.tracker_id=trackers.id AND hts.project_id=#{id} " +
              " AND (" + 
      ## Match for selected user_id
                  " hts.user_id=#{User.current.id} " +
      ## Match for selected role_id (BUT not for Anonymous and Not Member)
                " OR ((hts.role_id IS NOT NULL) AND hts.role_id IN (SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
                  " WHERE m.user_id=#{User.current.id} AND m.project_id=#{id})) " +
      ## Match for Anonymous user
                " OR (hts.role_id=2 AND 2=#{User.current.id})" +
      ## Match for Not Member user (Anonymous isn't a member as well, yeah)
                " OR ((hts.role_id=1) AND NOT EXISTS(SELECT mr.role_id FROM member_roles AS mr INNER JOIN members AS m ON mr.member_id=m.id " + 
                  " WHERE m.user_id=#{User.current.id} AND m.project_id=#{id})) " +
              ")" +
          ")"
        ).order(:position)
      end
      
        
    end
  end
  
end

Project.send(:include, TrackerHiderProjectPatch)
