class CreateHiddenTrackers < ActiveRecord::Migration
  def change
    create_table :hidden_trackers do |t|

      t.references :user, index: true, foreign_key: true

      t.references :project, index: true, foreign_key: true

      t.references :tracker, index: true, foreign_key: true


    end

  end
end
