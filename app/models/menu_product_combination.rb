class MenuProductCombination < ActiveRecord::Base
  belongs_to :menu_product
  belongs_to :combinations_rule
  belongs_to :combination_type
  belongs_to :menu_product
  belongs_to :product
  belongs_to :product_unit
  belongs_to :addons_group
  belongs_to :addons_group_product
  attr_accessible :combination_type_id, :menu_product_id, :price, :product_id, :combinations_rule, :combinations_rule_id,
              :combination_type, :ammount, :product_unit_id, :addons_group_id, :addons_group_product_id

  scope :by_product_and_group, lambda {|product_id,addons_group_id| where(["product_id=? AND addons_group_id=?",product_id,addons_group_id])}
end
