class CreateMenuMappings < ActiveRecord::Migration
  def change
    create_table :menu_mappings do |t|
      t.integer :day_id
      t.integer :section_id
      t.integer :menu_card_id
      t.integer :merge_section_id

      t.timestamps
    end
  end
end
