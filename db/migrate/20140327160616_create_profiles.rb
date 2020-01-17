class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :firstname,  null:false
      t.string :lastname,   null:false
      t.string :contact_no, null:false
      t.string :appurl,     null:false
      t.references :user

      t.timestamps
    end
    add_index :profiles, :user_id
  end
end
