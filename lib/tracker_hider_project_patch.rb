require_dependency 'project'

module TrackerHiderProjectPatch
  
  module IM
    
    def trackers_with_filter
      mrp = my_roles_in_project
      if mrp.empty? then
        trackers_without_filter.where("NOT EXISTS (SELECT * FROM hidden_trackers AS hts WHERE trackers.id=hts.tracker_id AND hts.project_id IS NULL AND hts.user_id IS NULL AND hts.role_id IS NOT NULL AND hts.role_id IN (1, 2))")
      else
        trackers_without_filter.where("NOT EXISTS (SELECT * FROM hidden_trackers AS hts WHERE trackers.id=hts.tracker_id AND hts.project_id IS NULL AND hts.user_id IS NULL AND hts.role_id IS NOT NULL AND hts.role_id IN (#{mrp.join(',')}))")
      end
    end
    
    def rolled_up_trackers_with_filter
      t = []
      hidden_a = []
      mrp = my_roles_in_project
      if mrp.empty? then
        hidden_a = HiddenTracker.where("project_id IS NULL AND user_id IS NULL AND role_id IS NOT NULL AND role_id IN (1, 2)").uniq.collect{|t| t.tracker_id}
      else  
        hidden_a = HiddenTracker.where("project_id IS NULL AND user_id IS NULL AND role_id IS NOT NULL AND role_id IN (#{mrp.join(',')})").uniq.collect{|t| t.tracker_id}
      end
      rolled_up_trackers_without_filter.each {|tr| t.push(tr) unless hidden_a.include?(tr[:id])}
      t
    end
    
    def my_roles_in_project
      members.where(user: User.current).collect{|r| r.id}
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
