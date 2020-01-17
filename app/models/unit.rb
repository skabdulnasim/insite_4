class Unit < ActiveRecord::Base    
  acts_as_paranoid
  attr_accessible :unit_name, :unittype_id, :pincode, :address, :landmark, :city, :state, :phone, 
                  :locality, :credit_limit, :unit_parent, :unit_image, :time_zone, :country, :latitude, :longitude, :unit_currency, :conversion_rate,
                  :sections_attributes, :stores_attributes, :sorts_attributes, :unit_images_attributes
                  
  has_attached_file :unit_image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :unit_image, :content_type => /\Aimage\/.*\Z/
  after_save :update_menu_product_conversion_price, if: :conversion_rate_changed?
  geocoded_by :address
  after_validation :geocode
  reverse_geocoded_by :latitude, :longitude, :address => :address

  TIMEZONES = { "Asia/Kolkata" => "Kolkata", "Asia/Abu Dhabi" => "Abu Dhabi" }

  belongs_to  :unittype
  has_many    :proformas
  has_many    :menu_cards, ->{where(:mode => 1)}, :class_name => 'MenuCard',  dependent: :restrict_with_exception
  has_many    :children, :foreign_key => "unit_parent", :class_name => "Unit"
  belongs_to  :parent_unit, :foreign_key => "unit_parent", :class_name => "Unit"
  has_many    :advertisements, through: :unit_advertisements
  has_many    :delivery_boys, through: :delivery_boys_units
  # has_many    :menu_products, through: :menu_cards
  has_many    :delivery_boys_units
  has_many    :unit_advertisements
  # has_many    :menu_categories
  has_many    :notifications
  has_one     :unit_detail
  has_many    :sections, ->{where( :is_trashed => false)}
  has_many    :printers
  has_many    :vendors
  has_many    :stores, dependent: :restrict_with_exception
  has_many    :sorts, dependent: :restrict_with_exception
  has_many    :users, ->{where(:is_trashed => false , :status => 1)}, dependent: :restrict_with_exception
  has_many    :pos_terminals, dependent: :restrict_with_exception
  has_many    :unit_products
  has_many    :products, :through => :unit_products
  has_many    :rooms
  has_many    :report_preferences, dependent: :restrict_with_exception
  has_and_belongs_to_many :alpha_promotions
  has_many    :news_events, through: :unit_news_events
  has_many    :unit_news_events
  has_many    :feedbacks, through: :unit_feedbacks
  has_many    :unit_feedbacks
  has_many    :type_of_cusines, through: :unit_type_of_cusines
  has_many    :unit_type_of_cusines
  has_many    :atmospheres, through: :unit_atmospheres
  has_many    :unit_atmospheres
  has_many    :more_infos, through: :unit_more_infos
  has_many    :unit_more_infos
  has_many    :outlet_types, through: :unit_outlet_types
  has_many    :unit_outlet_types
  has_many    :unit_images
  has_many    :slots
  has_many    :bill_destinations
  has_many    :questions, through: :question_units
  has_many    :question_units
  has_many    :delivery_charges
  has_many    :addons_groups
  has_one     :cancelation_policy
  has_one     :return_policy
  has_one     :financial_account,  as: :account_holder
  
  accepts_nested_attributes_for :sections, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :stores, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :sorts, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :unit_images, :allow_destroy => true, :reject_if => :all_blank

  validates :unit_name, :presence => true
  validates :unittype, :presence => true
  # validates :unit_parent, :presence => true
  # validates :unit_name, :unittype_id, :unit_parent, :pincode, :address, :city, :state, :phone, :locality, :credit_limit, :presence => true
  # validates_length_of :pincode, is: 6
  # validates_length_of :phone, is: 10
  #validates :unit_name, :presence => true, :uniqueness => {:message => "already subscribed"}
  #validates_length_of :phone, :minimum => 10, :maximum => 10
  #validates :phone, numericality: true, length: 10..10
  # to get unit name from id


  # => Model Scopes
  # scope :get_unit_name,   lambda {|parent_id| {:conditions=>{:id=>parent_id}}} # rails 4 comment
  scope :get_unit_name,   lambda {|parent_id|where("id=?",parent_id)}
  scope :set_parent_unit, lambda {|unit_id|where("unit_parent=?",unit_id)}
  scope :by_unit_parent,  lambda {|parent_unit_id|where(["unit_parent=?", parent_unit_id])}
  scope :set_id_in,       lambda {|unit_ids|where(["id in (?)", unit_ids])}
  scope :set_city,        lambda {|city|where(["city=?", city])}
  scope :non_trashed,     lambda { where(:is_trashed => false) }
  scope :by_unittype,     lambda { |unittype_id|where(["unittype_id=?",unittype_id])  }
  scope :by_unit_name,    lambda { |unit_name| where(["lower(unit_name) = ?",unit_name.downcase]) }
  scope :excluding_ids,   lambda { |ids| where(['id NOT IN (?)', ids])}
  scope :by_parent_id, lambda {|parent_id|where('unit_parent=?',parent_id)}

  def to_node
    unit_id = self.attributes['id']
    {
      "unit_id" => unit_id,
      "attributes" => self.attributes,      
      "children"   => self.children.map { |c| c.to_node },
      
    }
  end

  def self.set_unit_ids(parent_unit_id,arr_unit_id) # Recursion by ABDUL to get all unit id from children chain
    arr_unit_id.push(parent_unit_id)
    @c_units = Unit.set_parent_unit(parent_unit_id)

    @c_units.each do |cu|
      Unit.set_unit_ids(cu.id,arr_unit_id) # Recursion call
    end
    return arr_unit_id
  end

  def update_menu_product_conversion_price
    self.menu_cards.each do |menu_card|
      menu_card.menu_products.each do |mp|
        if mp.is_unit_currency == 'Yes'
          # mp.update_column(:unit_currency_price, mp.sell_price/self.conversion_rate)
          sell_price_wt = (mp.unit_currency_price * self.conversion_rate)
          mp.update_column(:sell_price, sell_price_wt)
          _tax_group = TaxGroup.find(mp.tax_group_id)
          if AppConfiguration.get_config_value('variable_tax') == 'enabled'
            @total_amnt = 0
            _tax_group.tax_classes.each do |tc|
              if tc.tax_type == 'variable'
                if (tc.lower_limit..tc.upper_limit).include?(mp.sell_price_without_tax)
                  @total_amnt = @total_amnt + tc[:ammount].to_f
                end 
              else
                @total_amnt = @total_amnt + tc[:ammount].to_f    
              end
            end
            _total_tax_percentage = @total_amnt
          else
            _total_tax_percentage = _tax_group.total_amnt.to_f
          end
          sell_price_wot = (sell_price_wt * 100) / (100+_total_tax_percentage)
          mp.update_column(:sell_price_without_tax, sell_price_wot)
        end  
      end  
    end
  end
     
end
