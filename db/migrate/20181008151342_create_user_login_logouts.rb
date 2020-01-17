class CreateUserLoginLogouts < ActiveRecord::Migration
  def change
    create_table :user_login_logouts do |t|
      t.string :user_name
      t.integer :sign_in_count, :default => 0
      t.datetime :last_sign_in_at

      t.timestamps
    end
  end
end
