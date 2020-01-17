class CreateCashOutDescriptions < ActiveRecord::Migration
  def change
    create_table :cash_out_descriptions do |t|
      t.integer :unit_id
      t.integer :user_id
      t.integer :count
      t.integer :cash_out_id

      t.timestamps
    end
  end
end
