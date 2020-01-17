class DeleteSelectedChannelInThirdpartyItemActions < ActiveRecord::Migration
  def up
    remove_column :thirdparty_item_actions, :selected_channel
  end

  def down
    add_column :thirdparty_item_actions, :selected_channel, :string
  end
end
