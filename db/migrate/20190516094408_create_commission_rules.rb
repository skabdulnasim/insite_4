class CreateCommissionRules < ActiveRecord::Migration
  def change
    create_table :commission_rules do |t|
      t.integer :resource_id
      t.integer :set_by
      t.string :month

      t.timestamps
    end
  end
end
