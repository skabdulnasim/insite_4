class CreateSaleRules < ActiveRecord::Migration
  def change
    create_table :sale_rules do |t|
      t.string :name
      t.string :status
      t.string :type
      t.date :valid_from
      t.date :valid_till

      t.timestamps
    end
  end
end
