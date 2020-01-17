class AddMenuCardIdToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :menu_card_id, :int
  end
end
