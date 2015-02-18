class AddEventbriteToUser < ActiveRecord::Migration
  def change
    add_column :users, :eventbrite_user_id, :string
    add_column :users, :eventbrite_access_token, :string
  end
end
