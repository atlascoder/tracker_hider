require_dependency 'project'

module TrackerHiderProjectPatch
  
  module IM
    
    def trackers_with_filter
      mrp = my_roles_in_project
      trackers_without_filter.where("NOT EXISTS (SELECT * FROM hidden_trackers AS hts WHERE trackers.id=hts.tracker_id AND hts.project_id IS NULL AND hts.user_id IS NULL AND hts.role_id IS NOT NULL AND hts.role_id IN (#{mrp.join(',')}))")
    end
    
    def rolled_up_trackers_with_filter
      t = []
      hidden_a = []
      mrp = my_roles_in_project
      hidden_a = HiddenTracker.where("project_id IS NULL AND user_id IS NULL AND role_id IS NOT NULL AND role_id IN (#{mrp.join(',')})").uniq.collect{|t| t.tracker_id}
      rolled_up_trackers_without_filter.each {|tr| t.push(tr) unless hidden_a.include?(tr[:id])}
      t
    end
    
    def my_roles_in_project
      m_s = []
      if User.current.anonymous? then
        m_s.push 2
      else
        m_s = members.where(user_id: User.current.id).collect{|r| r.id}
      end
      m_s.empty? ? [1] : m_s 
    end
    
  end
  
  def self.included(base)
    
    base.send(:include, IM)
    
    base.class_eval do
      has_many :hidden_trackers
      
      alias_method_chain :trackers, :filter
      alias_method_chain :rolled_up_trackers, :filter
        
    end
  end
  
end

Project.send(:include, TrackerHiderProjectPatch)
