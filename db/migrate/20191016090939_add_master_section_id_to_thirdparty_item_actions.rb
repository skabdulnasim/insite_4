class AddMasterSectionIdToThirdpartyItemActions < ActiveRecord::Migration
  def change
    add_column :thirdparty_item_actions, :master_section_id, :integer
    add_column :thirdparty_item_actions, :product_id, :integer
    add_column :thirdparty_item_actions, :unit_id, :integer
  end
end
