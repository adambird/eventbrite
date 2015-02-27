class AddCalendarIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :calendar_id, :string
  end
end
