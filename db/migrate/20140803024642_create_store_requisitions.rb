class CreateStoreRequisitions < ActiveRecord::Migration
  def change
    create_table :store_requisitions do |t|

      t.timestamps
    end
  end
end
