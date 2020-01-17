class AddStatusToMenuMappings < ActiveRecord::Migration
  def change
    add_column :menu_mappings, :status, :string
  end
end
