class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :access_token, null: false
      t.string :provider, null: false
      t.string :provider_id, null: false
      t.datetime :expired_at, null: false

      t.timestamps
    end
  end
end
