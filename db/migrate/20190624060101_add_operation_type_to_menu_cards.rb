class AddOperationTypeToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :operation_type, :string
  end
end
