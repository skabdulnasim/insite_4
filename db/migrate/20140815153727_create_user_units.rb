class CreateUserUnits < ActiveRecord::Migration
  def change
    create_table :user_units do |t|

      t.timestamps
    end
  end
end
