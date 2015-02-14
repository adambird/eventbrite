class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :cronofy_id
      t.string :cronofy_access_token
      t.string :cronofy_refresh_token

      t.timestamps null: false
    end
  end
end
