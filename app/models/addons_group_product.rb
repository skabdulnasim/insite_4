class AddonsGroupProduct < ActiveRecord::Base
  attr_accessible :addons_group_id, :product_id, :price, :ammount, :product_unit_id
  # :combination_type_id, :menu_product_id, :price, :product_id, :combinations_rule, :combinations_rule_id,
              # :combination_type, :ammount, :product_unit_id

  # Model Relations
  belongs_to :addons_group
  belongs_to :product
  belongs_to :product_unit
  has_many :menu_product_combinations

  # Model Validations
  validates :addons_group_id, :presence => true
  validates :product_id, :presence => true

  #Model Scope
  scope :by_product, lambda {|product_id| where(["product_id=?",product_id])}
  scope :by_addons_group_id_in, lambda {|addons_group_ids| where(["addons_group_id IN (?)",addons_group_ids])}
  scope :by_product_and_unit, lambda {|product_id,unit_id| where(["product_id=? AND product_unit_id=?",product_id,unit_id])}
  scope :by_product_and_punit_and_qnt_and_unit, lambda {|product_id,product_unit_id,qnt,unit_id| where(["product_id=? AND product_unit_id=? AND ammount=? AND addons_group_id IN(SELECT id FROM addons_groups WHERE unit_id=?)",product_id,product_unit_id,qnt,unit_id])}

  def self.save_addons_group_products(addons_group_id, product_ids)
  	prev = self.where('addons_group_id =?', addons_group_id)
    prev.destroy_all if prev.present?
  	product_ids.each do |product_id|
  	  AddonsGroupProduct.create(:addons_group_id => addons_group_id, :product_id => product_id)
    end
  end


end