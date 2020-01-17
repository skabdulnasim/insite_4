class CreateTaxClasses < ActiveRecord::Migration
  def change
    create_table :tax_classes do |t|
      t.string :name

      t.timestamps
    end
  end
end
