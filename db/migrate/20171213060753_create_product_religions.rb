class CreateProductReligions < ActiveRecord::Migration
  def change
    create_table :product_religions do |t|
      t.string :name

      t.timestamps
    end
  end
end
