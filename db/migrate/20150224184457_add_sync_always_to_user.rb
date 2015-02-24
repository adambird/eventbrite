class AddSyncAlwaysToUser < ActiveRecord::Migration
  def change
    add_column :users, :sync_always, :boolean
  end
end
