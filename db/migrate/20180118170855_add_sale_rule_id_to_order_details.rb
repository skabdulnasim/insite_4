class AddSaleRuleIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :sale_rule_id, :integer
    add_column :order_details, :discount_detail, :text
  end
end
