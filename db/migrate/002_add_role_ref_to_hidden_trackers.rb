class AddRoleRefToHiddenTrackers < ActiveRecord::Migration
  def change
    add_reference :hidden_trackers, :role, index: true
  end
end
