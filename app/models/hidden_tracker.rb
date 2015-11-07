class HiddenTracker < ActiveRecord::Base
  belongs_to :tracker
  belongs_to :project
  belongs_to :user
  unloadable
end
