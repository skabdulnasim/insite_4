class AddMenuCardIdToLots < ActiveRecord::Migration
  def change
    add_column :lots, :menu_card_id, :integer
  end
end
