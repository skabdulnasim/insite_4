class CreateUserResources < ActiveRecord::Migration
  def change
    create_table :user_resources do |t|
      t.integer :user_id
      t.integer :resource_id
      t.string :day

      t.timestamps
    end
  end
end
