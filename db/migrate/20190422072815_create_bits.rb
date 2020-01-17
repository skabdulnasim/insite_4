class CreateBits < ActiveRecord::Migration
  def change
    create_table :bits do |t|
      t.string :name
      t.string :parent_bit
      t.text :area_descriptions

      t.timestamps
    end
  end
end
