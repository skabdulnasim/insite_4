class MenuCard < ActiveRecord::Base
  attr_accessible :mode, :name, :valid_from, :valid_till, :unit_id, :trash, :section_id, :master_menu_id, :scope, :menu_type, :image, :priority, :position,
                  :menu_products_attributes, :menu_categories_attributes, :operation_type, :menu_classification, :sort_items_by, :sort_order

  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  ### => Model relations
  belongs_to :unit
  has_many :advertisement
  belongs_to :section
  has_many :menu_products, :dependent => :destroy
  has_many :menu_products_variable_nil,->{where(:mode => 1, :variable_id => nil , :combo_id => nil) },:class_name => 'MenuProduct'
  has_many :menu_categories, :dependent => :destroy
  has_many :menu_categories_variable_nil, ->{where(:is_visible => true)}, :class_name => 'MenuCategory'
  has_many :parent_menu_categories,->{where(:parent => nil)}, class_name: 'MenuCategory' 
  has_many :tax_groups,-> { distinct }, :through => :menu_products
  has_many :clone_menu_cards, class_name: "MenuCard",
                          foreign_key: "master_menu_id"
  belongs_to :master_menu_card, class_name: "MenuCard", foreign_key: "master_menu_id"


  accepts_nested_attributes_for :menu_products, :reject_if => proc { |a| a[:product_id].blank? }, allow_destroy: true
  accepts_nested_attributes_for :menu_categories, :reject_if => proc { |a| a[:name].blank? }, allow_destroy: true
  after_save :update_unit_id
  after_create :clone,
                  if: Proc.new { |menu_card| menu_card.master_menu_id.present? }
  ### => Model validations
  validates :name,        :presence => true
  validates :scope,       :presence => true
  validates :unit_id,     :presence => true
  validates :section_id,  :presence => true

  ### => Model Scopes
  scope :set_unit,      lambda {|unit_id|where(["menu_cards.unit_id=?", unit_id])}
  scope :set_section,   lambda {|section_id|where(["section_id=?", section_id])}
  scope :set_scope,     lambda {|scope|where(["scope=?", scope])}
  scope :set_mode,      lambda {|mode|where(["mode=?", mode])}
  scope :not_trashed,   lambda { where(:trash => nil) }
  scope :active,        lambda { where(["mode = ?",1]) }
  scope :inhouse,       lambda { where(["scope = ?",'inhouse']) }
  scope :hungryleopard, lambda { where(["scope = ?",'hungryleopard']) }
  scope :by_unit_in,    lambda { |unit_ids| where(["unit_id IN (?)", unit_ids])  }
  scope :by_master_menu_id,  lambda {|master_menu_id|where(["master_menu_id=?", master_menu_id])}
  scope :set_operation_type, lambda {|operation_type|where(["operation_type=?", operation_type])}
  scope :by_id, lambda {|id| where(["id=?",id])}
  scope :by_menu_card_in,    lambda { |mc_ids| where(["id IN (?)", mc_ids])} # Code By ABDUL

  # Code By ABDUL START
  def self.set_copy_menu_ids(parent_menu_id,arr_menu_id) # Recursion to get Parent Child's Child menu_card_id
    arr_menu_id.push(parent_menu_id)
    @c_menus = MenuCard.by_master_menu_id(parent_menu_id)

    @c_menus.each do |cm|
      MenuCard.set_copy_menu_ids(cm.id,arr_menu_id) # Recursion call
    end
    return arr_menu_id
  end
  # Code By ABDUL END

  def active?
    self.mode == 1
  end

  def update_unit_id
    self.update_column(:unit_id, self.section.unit_id)
  end

  def clone
    # Clone manu categories
    clone_categories
  end

  def clone_categories
    self.master_menu_card.parent_menu_categories.each do |category|
      new_category = category.dup
      self.menu_categories << new_category
      new_category.reload
      # Assign new category ID to products
      update_product_category new_category.id, category.id
      # Clone subcategories if exist
      clone_subcategories category, new_category if category.submenucategories.present?
    end
  end

  def clone_subcategories old_category, new_category
    old_category.submenucategories.each do |category|
      new_subcategory = category.dup
      new_category.submenucategories << new_subcategory
      new_subcategory.reload
      # Assign new category ID to products
      update_product_category new_subcategory.id, category.id
      # Clone subcategories if exist
      clone_subcategories category, new_subcategory if category.submenucategories.present?
    end
  end

  def update_product_category new_category_id, old_category_id
    self.menu_products.each do |product|
      product.update_attribute(:menu_category_id, new_category_id) if product.menu_category_id == old_category_id
    end
  end

  def self.get_all_units_by_menu_card_id(menu_card_id)
  	_menu_cards = MenuCard.where( master_menu_id: menu_card_id)
  	return _menu_cards
  end

  def self.each_mode_toggle(menu_card_id)
    _menu_card = MenuCard.find(menu_card_id)
    if _menu_card[:mode].nil? || _menu_card[:mode] == 0
      _menu_card[:mode] = 1
    else
      _menu_card[:mode] = 0
    end
    _menu_card.save
  end

  def self.menu_exist(section_id, unit_id, from_menu_id)
    # details = MenuCard.find(:all, :conditions => ['section_id =? AND unit_id =? AND master_menu_id =?', section_id, unit_id, from_menu_id])
    details = MenuCard.where("section_id =? AND unit_id =? AND master_menu_id =?",section_id, unit_id, from_menu_id)
    return details
  end
end
