class MenuProduct < ActiveRecord::Base
  acts_as_paranoid
  audited
  attr_accessible :menu_card_id, :menu_category_id, :product_id, :sell_price, :sell_price_without_tax, :procured_price, :mode, :cost_category_id,
                  :stock_qty, :stock_status, :variable_id, :tax_group_id, :store_id, :isdefault, :sort_id, :combo_id, :is_buffet_product, :alpha_promotion_id, :bill_destination_id, :delivery_mode, :max_order_qty, :commission_capping, :commission_capping_type,
                  :menu_product_combinations_attributes, :combo_items_attributes, :tag_ids, :is_unit_currency, :unit_currency_price

  DELIVERY_MODES = %w( Standard Express )
  COMMISSION_CAPPING_TYPE = %w( By_amount By_percentage )

  # => Model Validations
  validates :menu_category_id, :presence => true
  # validates :product_id, :presence => true
  validates :mode, :presence => true
  #validates_uniqueness_of :product_id, :scope => :menu_card_id, :message => "already exist"

  # => Model aassociations
  belongs_to :menu_category
  belongs_to :cost_category
  belongs_to :tax_group
  belongs_to :menu_card
  belongs_to :product
  belongs_to :store
  belongs_to :sort
  has_one :alpha_promotion
  has_many :menu_product_combinations, :dependent => :destroy
  has_many :combination_types, ->{distinct},through: :menu_product_combinations
  has_many :combinations_rules,->{distinct} ,through: :menu_product_combinations
  has_many :variants, :class_name => "MenuProduct", :foreign_key => :variable_id
  has_many :combos, :class_name => "MenuProduct", :foreign_key => :combo_id
  has_many :combo_items, :dependent => :destroy
  has_many :lots
  has_many :menu_product_sale_rules
  has_many :sale_rules, :through => :menu_product_sale_rules
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :menu_product_combinations, :reject_if => proc { |a| a[:product_id].blank? }, allow_destroy: true
  accepts_nested_attributes_for :combo_items
  
  delegate  :name, :basic_unit,
            :to => :product,
            :prefix => true

  # before_validation :assign_tax_group
  before_create :add_stock_details
  after_touch :push_update_to_menucard
  after_create :push_update_to_menucard
  after_create :clone_variable_and_combo_items, if: :master_menu_present?
  after_create :assign_tax_group
  after_save :calculate_unit_currency_value
  # after_update :copy_menu_product_update
  # => Model Scopes
  scope :set_product_and_section,   lambda {|product_id,section_id|where(["product_id=? AND menu_card_id=(SELECT id FROM menu_cards WHERE section_id=? AND mode=1)", product_id,section_id])}
  scope :set_product,   lambda {|product_id|where(["product_id=?", product_id])}
  scope :set_store,     lambda {|store_id|where(["store_id=?", store_id])}
  scope :by_menu_card,  lambda {|menu_card_id|where(["menu_card_id=?", menu_card_id])}
  scope :by_menu_card_and_category,  lambda {|menu_card_id,menu_category_id|where(["menu_card_id=? AND menu_category_id=?", menu_card_id,menu_category_id])}
  
  scope :active,        lambda { where(["mode = ?",1]) }
  scope :filter_by_menu_category, lambda {|menu_category_id| where(["menu_category_id=?", menu_category_id])}
  scope :set_product_in, lambda{|products| where(["product_id in (?)", products])}
  scope :set_menu_product_in, lambda{|menu_products| where(["id in (?)", menu_products])}
  scope :set_menu_card_in, lambda {|menu_card_ids| where(["menu_card_id in (?)", menu_card_ids])}
  scope :set_sub_category_ids, lambda {|subcategory_ids| where(["menu_category_id in (?)", subcategory_ids])}
  scope :not_deleted,        lambda { where(["deleted_at IS NULL"]) }
  scope :by_menu_card_and_addons_group,  lambda {|menu_card_id, addons_group_id|where(["menu_card_id = ? AND id IN ( SELECT menu_product_id FROM menu_product_combinations WHERE addons_group_id = ? )", menu_card_id, addons_group_id])}

  # def copy_menu_product_update
  #   puts "************___________*************"
  #   _mc_id = self.menu_card.id
  #   _all_mc_ids = []
  #   _all_mc_ids = MenuCard.set_copy_menu_ids(_mc_id,_all_mc_ids)
  #   puts _all_mc_ids.inspect
  # end

  def active?
    self.mode == 1
  end

  def child_menu_product(unit_id)
    product_id = self.product.id
    master_section = self.menu_card.section
    child_section = Section.unit_section_by_master_section(unit_id,master_section.id).first
    if child_section.present?
      _child_menu_product = MenuProduct.set_product_and_section(product_id,child_section.id).first
      return _child_menu_product.present? ? _child_menu_product : nil
    else
      return nil
    end
  end

  def parent_menu_product
    product_id = self.product.id
    child_section = self.menu_card.section
    if child_section.master_section_id.present?
      master_section = Section.find(child_section.master_section_id)
      if master_section.present?
        _master_menu_product = MenuProduct.set_product_and_section(product_id,master_section.id).first
        return _master_menu_product.present? ? _master_menu_product : nil
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.active_menu_product(store_id,product_id)
    menu_product = set_store(store_id).set_product(product_id).active.first
  end

  def assign_tax_group
    if master_menu_present?
      update_attribute(:tax_group_id, set_tax_group) unless self.tax_group_id.present?
    end
    update_attribute(:sell_price, compute_sell_price)
  end

  def set_tax_group
    identical_tax_group = self.menu_card.section.tax_groups.find_by_total_amnt(master_menu_item.tax_group.total_amnt)
    tax_group = identical_tax_group.present? ? identical_tax_group.id : clone_tax_group.id
  end

  def clone_tax_group
    new_tax_group = master_menu_item.tax_group.dup
    self.menu_card.section.tax_groups << new_tax_group
    new_tax_group.reload
    master_menu_item.tax_group.tax_classes.map { |tax_class|  new_tax_group.tax_classes << tax_class }
    return new_tax_group
  end

  def clone_variable_and_combo_items
    # Clone combo item
    clone_combo_product if self.combo_id.present?
    # Clone variable item
    clone_variable_product if self.variable_id.present?
  end

  def clone_combo_product
    source_combo = MenuProduct.find(self.combo_id)
    clone_combo = self.menu_card.menu_products.set_product(source_combo.product_id).first
    update_attribute(:combo_id, clone_combo.id)
  end

  def clone_variable_product
    source_variable = MenuProduct.find(self.variable_id)
    clone_variable = self.menu_card.menu_products.set_product(source_variable.product_id).first
    update_attribute(:variable_id, clone_variable.id)
  end

  def calculate_unit_currency_value
    if self.is_unit_currency == "Yes" && self.unit_currency_price == 0
      unit = self.menu_card.unit
      if unit.unit_currency.present?
        if unit.conversion_rate.present?
          self.update_column(:unit_currency_price, self.sell_price/unit.conversion_rate)
        end  
      end  
    end 
  end

  def master_menu_item
    self.menu_card.master_menu_card.menu_products.set_product(self.product_id).first
  end

  def master_menu_present?
    self.menu_card.master_menu_id.present?
  end

  def child_menu_present?
    MenuCard.by_master_menu_id(self.id).present?
  end

  # def compute_sell_price
  #   (self.sell_price_without_tax.to_f + (self.sell_price_without_tax.to_f * self.tax_group.total_amnt.to_f / 100)).round
  # end

  def compute_sell_price
    if AppConfiguration.get_config_value('variable_tax') == 'enabled'
      _total_amnt = 0
      self.tax_group.tax_classes.each do |tc|
        if tc.tax_type == 'variable'
          if (tc.lower_limit..tc.upper_limit).include?(self.sell_price_without_tax)
            _total_amnt = _total_amnt + tc[:ammount].to_f
          end 
        end
      end
      (self.sell_price_without_tax.to_f + (self.sell_price_without_tax.to_f * _total_amnt.to_f / 100)).round
    else  
      (self.sell_price_without_tax.to_f + (self.sell_price_without_tax.to_f * self.tax_group.total_amnt.to_f / 100)).round
    end
  end

  def self.get_menu_products(menu_card_id, product_type)
    MenuProduct.joins(:product).where("menu_card_id =? AND products.product_type =?", menu_card_id, product_type)
  end

  def self.get_products(product_type)
    products = Product.where('product_type = (?)',product_type)
  end

  def self.import(file,menu_card_id,unit_id,section_id)
    imported_menu_products =Array.new
    data_errors = Array.new
    CSV.foreach(file.path, headers: true) do |row|
      product =Product.find_by_name(row["product"])
      cost_category = row["cost_category"].present? ? CostCategory.find_by_name(row["cost_category"]) : nil
      if MenuProduct.find_by_product_id_and_menu_card_id(product.id,menu_card_id).present?
        menu_product = MenuProduct.find_by_product_id_and_menu_card_id(product.id,menu_card_id)
        menu_product.attributes = row.to_hash.slice(*MenuProduct.accessible_attributes)
      else
        menu_product = MenuProduct.new
        menu_product.attributes = row.to_hash.slice(*MenuProduct.accessible_attributes)
      end
      # menu_product = MenuProduct.new
      # menu_product.attributes = row.to_hash.slice(*MenuProduct.accessible_attributes)
      # product =Product.find_by_name(row["product"])
      if MenuCategory.find_by_name_and_unit_id(row["sub_menu_category_name"],unit_id).present?
        # menu_category = MenuCategory.find_by_name_and_unit_id_and_menu_card_id(row["sub_menu_category_name"],unit_id,menu_card_id)
        menu_category = MenuCategory.find_by_name_and_menu_card_id(row["sub_menu_category_name"],menu_card_id)
      else
        # menu_category = MenuCategory.find_by_name_and_unit_id_and_menu_card_id(row["parent_menu_category_name"],unit_id,menu_card_id)
        menu_category = MenuCategory.find_by_name_and_menu_card_id(row["parent_menu_category_name"],menu_card_id)
      end

      # menu_category = MenuCategory.find_by_id_and_unit_id(row["menu_category_name"],unit_id) || MenuCategory.find_by_name_and_unit_id(row["menu_category_name"],unit_id)
      tax_group = TaxGroup.find_by_name_and_section_id(row["tax_group"],section_id)
      store = Store.find_by_name_and_unit_id(row["store"],unit_id)      
      sort = Sort.find_by_name_and_unit_id(row["sort"],unit_id)  
      bill_destination = BillDestination.find_by_name_and_unit_id(row["bill_destination"],unit_id) if row["bill_destination"].present?
      sell_price = (row["sell_price_without_tax"].to_f + (row["sell_price_without_tax"].to_f * tax_group.total_amnt.to_f / 100)).round
      delivery_mode = row["delivery_mode"].present? ? row["delivery_mode"].humanize : 'Standard'
      max_order_qty = row["maximum_order_quantity"].present? ? row["maximum_order_quantity"] : ''

      if MenuProduct.find_by_product_id_and_menu_card_id(product.id,menu_card_id).present?
        menu_product[:product_id] = product.present? ? product.id : nil
        menu_product[:menu_category_id] = menu_category.present? ? menu_category.id : nil
        menu_product[:menu_card_id] = menu_card_id.present? ? menu_card_id : nil
        menu_product[:tax_group_id] = tax_group.present? ? tax_group.id : nil
        menu_product[:store_id] = store.present? ? store.id : nil
        menu_product[:sort_id] = sort.present? ? sort.id : nil
        menu_product[:mode] = 1
        menu_product[:sell_price] = sell_price
        menu_product[:bill_destination_id] = bill_destination.present? ? bill_destination.id : nil if bill_destination.present?
        menu_product[:delivery_mode] = delivery_mode
        menu_product[:max_order_qty] = max_order_qty
        if cost_category.present?
          menu_product[:cost_category_id] = cost_category.present? ? cost_category.id : nil
        end
        menu_product[:commission_capping_type] = row["commission_capping_type"]
        menu_product[:commission_capping] = row["commission_capping"]
        imported_menu_products.push menu_product
      else
        menu_product[:product_id] = product.present? ? product.id : nil
        menu_product[:menu_category_id] = menu_category.present? ? menu_category.id : nil
        menu_product[:menu_card_id] = menu_card_id.present? ? menu_card_id : nil
        menu_product[:tax_group_id] = tax_group.present? ? tax_group.id : nil
        menu_product[:store_id] = store.present? ? store.id : nil
        menu_product[:sort_id] = sort.present? ? sort.id : nil
        menu_product[:mode] = 1
        menu_product[:sell_price] = sell_price
        menu_product[:bill_destination_id] = bill_destination.present? ? bill_destination.id : nil if bill_destination.present?
        menu_product[:delivery_mode] = delivery_mode
        menu_product[:max_order_qty] = max_order_qty
        if cost_category.present?
          menu_product[:cost_category_id] = cost_category.present? ? cost_category.id : nil
        end
        # menu_product[:cost_category_id] = cost_category.id.present? ? cost_category.id : nil if cost_category.present?
        menu_product[:commission_capping_type] = row["commission_capping_type"]
        menu_product[:commission_capping] = row["commission_capping"]
        
        imported_menu_products.push menu_product
      end

    end
    if imported_menu_products.map(&:valid?).all?
      imported_menu_products.each(&:save!)
      true
    else
      imported_menu_products.each_with_index do |product, index|
        unless product.valid?
          errors_messages = self.error_messages_for(product)
          data_errors.push("Row #{index+2}: #{errors_messages}")
        end
      end
      error_str = data_errors.map { |e| e }.join(', ')
      raise "Data of #{data_errors.size} row(s) prevented the form being saved. #{error_str}"
    end
  end

  def self.error_messages_for(*objects)
    error_string = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    error_string = errors.map { |e|  "#{e}" }.join(', ') if errors.any?
  end 

  def self.filter_by_string(searcing_text)
    if searcing_text.present?
      self.joins(:product).where("lower(products.name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end    
  end

  def self.filter_by_sku(menu_products,sku)
    if sku.present?
      menu_products.joins(:lots).where("lots.sku LIKE (?)", "%#{sku}%").uniq
    end
  end

  def self.filter_by_brand_name(searching_text)
    if searching_text.present?
      self.joins(:product).where("lower(products.brand_name) LIKE ?", "%#{searching_text.downcase}%")
    else
      all
    end
  end

  def self.filter_by_name_and_brand_name(searching_text)
    if searching_text.present?
      self.joins(:product).where("lower(products.name) LIKE ? OR lower(products.brand_name) LIKE ?", "%#{searching_text.downcase}%", "%#{searching_text.downcase}%")
    else
      all
    end    
  end

  #################################################################################

  private

  # => PUSH service for all subscribers
  def push_update_to_menucard
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels=Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/menu_card/'+self.menu_card_id.to_s+'/product_update'
    _hash = {:type => 'menu_product_update', :json_data => self}
    Notification.publish_in_faye(_channels,_hash)
  end

  def add_stock_details
    _current_stock = StockUpdate.current_stock(self.store_id, self.product_id)
    self.stock_status = _current_stock > 0 ? 1 : 0
    self.stock_qty = _current_stock
  end
end
