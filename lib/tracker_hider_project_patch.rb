require_dependency 'project'

module TrackerHiderProjectPatch
  
  def self.included(base)
    
    base.class_eval do
      has_many :hidden_trackers
    end
      
  end
  
end

Project.send(:include, TrackerHiderProjectPatch)
