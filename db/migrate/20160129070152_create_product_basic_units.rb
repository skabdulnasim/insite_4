class CreateProductBasicUnits < ActiveRecord::Migration
  def change
    create_table :product_basic_units do |t|
      t.string :name
      t.string :short_name
      t.timestamps
    end
    ProductBasicUnit.create(:name=>"Kilogram", :short_name=>"Kg")
    ProductBasicUnit.create(:name=>"Litre", :short_name=>"lt")
    ProductBasicUnit.create(:name=>"Piece", :short_name=>"Pc")
  end
end
