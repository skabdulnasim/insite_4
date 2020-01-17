class AddUniqIdentyNoToResources < ActiveRecord::Migration
  def change
    add_column :resources, :unique_identity_no, :string
  end
end
