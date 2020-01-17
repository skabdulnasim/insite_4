class AddUnitIdToBits < ActiveRecord::Migration
  def change
    add_column :bits, :unit_id, :integer
  end
end
