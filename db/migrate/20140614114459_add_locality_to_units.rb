class AddLocalityToUnits < ActiveRecord::Migration
  def change
    add_column :units, :locality, :string
  end
end
