class AddProductionStatusToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :production_status, :string
  end
end
