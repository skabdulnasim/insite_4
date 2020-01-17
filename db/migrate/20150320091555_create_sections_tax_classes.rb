class CreateSectionsTaxClasses < ActiveRecord::Migration
  def up
    create_table :sections_tax_classes, :id => false do |t|
      t.integer "section_id"
      t.integer "tax_class_id"
    end
    add_index :sections_tax_classes, ["section_id","tax_class_id"]
  end

  def down
  end
end
