class AddClientTypeToSettlements < ActiveRecord::Migration
  def change
    add_column :settlements, :client_type, :string
  end
end
