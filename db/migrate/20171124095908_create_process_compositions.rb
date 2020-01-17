class CreateProcessCompositions < ActiveRecord::Migration
  def change
    create_table :process_compositions do |t|
      t.integer :product_id
      t.integer :production_process_id

      t.timestamps
    end
  end
end
