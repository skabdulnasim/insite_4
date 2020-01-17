class CreateTaxGroupsTaxClasses < ActiveRecord::Migration
  def up
    create_table :tax_classes_tax_groups, :id => false do |t|
      t.integer "tax_group_id"
      t.integer "tax_class_id"
    end
    add_index :tax_classes_tax_groups, ["tax_group_id","tax_class_id"]
  end

  def down
  end
end
