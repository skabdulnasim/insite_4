class AddonsGroup < ActiveRecord::Base
  attr_accessible :title, :unit_id, :min_selectable, :max_selectable, :section_id

  # Model Relations
  has_many :products, through: :addons_group_products
  has_many :addons_group_products
  has_many :menu_product_combinations
  belongs_to :section

  scope :set_product_master,   	lambda {|product_id,unit_id|where(["id IN ( SELECT addons_group_id FROM addons_group_products WHERE product_id=? ) AND unit_id=?", product_id,unit_id])}
  scope :set_menu_card,   			lambda {|menu_card_id|where(["id IN ( SELECT addons_group_id FROM menu_product_combinations WHERE menu_product_id IN ( SELECT id FROM menu_products WHERE menu_card_id = ? ) )", menu_card_id])}
  scope :set_section,   				lambda {|section_id|where(["section_id=?", section_id])}
  scope :set_product_master_section,   	lambda {|product_id,unit_id,section_id|where(["id IN ( SELECT addons_group_id FROM addons_group_products WHERE product_id=? ) AND unit_id=? AND section_id=? ", product_id,unit_id,section_id])}

end