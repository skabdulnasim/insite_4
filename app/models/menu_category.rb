class MenuCategory < ActiveRecord::Base
  acts_as_paranoid
  
  attr_accessible :description, :name, :menu_category_image, :parent, :unit_id, :menu_card_id, :unit_parent,:image,:sort_order,:is_parent_visible

  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  
  # => Model aassociations
  belongs_to :unit
  belongs_to :menu_card
  has_many :menu_products, :dependent => :destroy
  has_many :menu_products_variable_nil,->{where(:mode => 1, :variable_id => nil , :combo_id => nil)} , :class_name => 'MenuProduct'

  has_many :submenucategories, ->{where(:is_visible => true)},:class_name => "MenuCategory", :foreign_key => :parent
  belongs_to :parent_category, class_name: "MenuCategory", foreign_key: "parent"
  #has_one :parent, :class_name => "Category", :primary_key => :parent, :foreign_key => :id
  has_many :menu_category_sale_rules
  has_many :sale_rules, :through => :menu_category_sale_rules
  has_many :category_item_preferences
  has_many :item_preferences, through: :category_item_preferences
  after_create :set_attributes
  # => Scope methods
  scope :menu_parent, lambda {|query| where("id=?", query)}
  scope :get_menu_categories, lambda {|menu_card_id| where("menu_card_id=?", menu_card_id)}
  scope :get_root_categories, lambda { where(:parent => nil) }
  # scope :set_parent_category, lambda {|parent_id| {:conditions=>{:parent=>parent_id}}}
  scope :set_parent_category, lambda {|parent_id| where("parent=?",parent_id)}
  scope :by_id,               lambda {|id| where("id=?", id)}

  def self.import(file,unit_id,menu_card_id)
    CSV.foreach(file.path, headers: true) do |row|
      menu_category = MenuCategory.new
      _parent_id=""
      if row["parent_menu_category_name"].present?
        _parent_id=MenuCategory.find_by_name_and_menu_card_id(row["parent_menu_category_name"],menu_card_id).present? ? MenuCategory.find_by_name_and_menu_card_id(row["parent_menu_category_name"],menu_card_id).id : ''
        if _parent_id == ""
          menu_category_parent = MenuCategory.new
          menu_category_parent.attributes = {:name => row["parent_menu_category_name"], :unit_id => unit_id,:menu_card_id => menu_card_id}
          menu_category_parent.save
          _parent_id=menu_category_parent.id
        end
        if !MenuCategory.find_by_name_and_menu_card_id(row["sub_menu_category_name"],menu_card_id).present?
          menu_category.attributes = {:name => row["sub_menu_category_name"], :parent=>_parent_id, :unit_id => unit_id,:menu_card_id => menu_card_id}
          menu_category.save
        end
      else
        if !MenuCategory.find_by_name_and_menu_card_id(row["sub_menu_category_name"],menu_card_id).present?
          menu_category.attributes = {:name => row["sub_menu_category_name"], :parent=>"", :unit_id => unit_id,:menu_card_id => menu_card_id}
          menu_category.save
        end
      end
    end
  end

  def visible?
    is_visible
  end

  private
  
  def set_attributes
    menu_card_id = self.parent_category.menu_card_id if self.parent_category.present?
    self.update_attribute(:menu_card_id,menu_card_id)
  end
end
