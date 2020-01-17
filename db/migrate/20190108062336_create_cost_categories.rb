class CreateCostCategories < ActiveRecord::Migration
  def change
    create_table :cost_categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
