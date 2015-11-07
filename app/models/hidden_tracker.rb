class HiddenTracker < ActiveRecord::Base
  belongs_to :tracker
  belongs_to :project
  belongs_to :user
  belongs_to :role
  unloadable
end
