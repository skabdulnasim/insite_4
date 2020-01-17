class AddStatusToSimo < ActiveRecord::Migration
  def change
    add_column :simos, :status, :string
  end
end
