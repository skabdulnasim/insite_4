class CreateTaxGroups < ActiveRecord::Migration
  def change
    create_table :tax_groups do |t|
      t.string :name
      t.integer :section_id

      t.timestamps
    end
  end
end
