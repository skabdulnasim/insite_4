class AlterTableToLoyaltyCard < ActiveRecord::Migration
  def change
    add_column    :loyalty_cards, :card_no, :string, :after => :id
    remove_column :loyalty_cards, :card_class
    add_column    :loyalty_cards, :loyalty_card_class_id, :integer
    add_index     :loyalty_cards, :loyalty_card_class_id
  end
end
