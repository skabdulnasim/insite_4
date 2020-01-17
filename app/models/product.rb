class Product < ActiveRecord::Base
  acts_as_paranoid
  audited
  require 'uri'
  attr_accessible   :name, :local_name, :product_type, :category_id, :parent, :business_type, :physical_type_id, :basic_unit_id, :hsn_code, :item_code, :brand_name, :mfr_name, :conjugated_unit, :conjugated_unit_id, :callorie, :product_religion_id, :thresh_hold, :brand_code, :p_code,
                    :product_attribute_set_id, :package_component_id, :properties_attributes, :compositions_attributes, :process_compositions_attributes, :product_images_attributes, :color_products_attributes, :product_sizes_attributes, :vendor_products_attributes, :menu_products_attributes, :product_tags_attributes

  # => Defining product types
  PRODUCT_TYPE = %w(simple variable combo)
  
  # => Defining product business types
  BUSINESS_TYPE = %w(by_catalog by_mrp by_weight by_bulk_weight) 

  # Defining virtual attributes for response.
  VIRTUAL_ATTRIBUTES = %w(basic_unit product_image short_name sku short_description)

  # => Defining Relations

  belongs_to :category
  belongs_to :product_unit
  belongs_to :product_attribute_set
  belongs_to :measurement_unit, :class_name => "ProductBasicUnit", :foreign_key => :basic_unit_id
  belongs_to :product_religion
  belongs_to :package_component
  # *START* Below relations may be DEPRECATED, will be removed soon
  # belongs_to :unittype
  # belongs_to :physical_type
  # *END*

  has_many :properties, :class_name => "ProductAttributeValue", :foreign_key => :product_id, dependent: :destroy
  has_many :product_compositions, dependent: :destroy
  has_many :compositions, :class_name => "ProductComposition", :foreign_key => :product_id, dependent: :destroy
  has_many :unit_products
  has_many :units, :through => :unit_products
  has_many :vendor_products
  has_many :vendors, :through => :vendor_products
  has_many :menu_products
  has_many :store_products
  has_many :stores, :through => :store_products
  has_many :input_units, ->{where(:transaction_type => 'input')}, :class_name => "ProductTransactionUnit", :foreign_key => :product_id
  has_many :output_units,->{where(:transaction_type => 'output')},:class_name => "ProductTransactionUnit", :foreign_key => :product_id
  has_many :stocks
  has_many :product_images
  has_many :allergy_products
  has_many :allergies, :through => :allergy_products
  has_many :process_compositions, :foreign_key => :product_id, dependent: :destroy
  has_many :simo_output_product
  has_many :simo_output_product_template
  has_many :color_products
  has_many :colors, :through => :color_products
  has_many :product_sizes
  has_many :sizes, :through => :product_sizes
  # *START* Below relations may be DEPRECATED, will be removed soon
  has_many :product_meta, dependent: :destroy
  has_many :product_attributes
  has_many :product_attrs, through: :product_attributes, source: :p_attribute
  has_many :subproducts, :class_name => "Product", :foreign_key => :parent
  has_one :parentproduct, :class_name => "Product", :primary_key => :parent, :foreign_key => :id
  has_many :bin_products
  has_many :product_transaction_units
  has_many :lots
  has_many :product_tags
  has_many :tags, :through => :product_tags
  # *END*

  accepts_nested_attributes_for :properties, allow_destroy: true
  accepts_nested_attributes_for :compositions, allow_destroy: true
  accepts_nested_attributes_for :process_compositions, allow_destroy: true
  accepts_nested_attributes_for :product_images, allow_destroy: true
  accepts_nested_attributes_for :color_products, allow_destroy: true
  accepts_nested_attributes_for :product_sizes, allow_destroy: true
  accepts_nested_attributes_for :vendor_products, allow_destroy: true
  accepts_nested_attributes_for :menu_products, allow_destroy: true
  accepts_nested_attributes_for :product_tags, allow_destroy: true


  ### => Model callbacks
  before_validation :set_attributes
  after_save :generate_product_serial_code

  # => Defining Validations
  validates :name,                  :presence => true, 
                                    :uniqueness => true,
                                    :length => { :maximum => 500 }
  validates :product_type,          :inclusion => {:in => PRODUCT_TYPE }
  validates :business_type,         :inclusion => {:in => BUSINESS_TYPE }
  validates :category,              :presence => true
  validates :basic_unit_id,         :presence => true
  validates :product_attribute_set, :presence => true

  delegate  :name, :basic_unit,
            :to => :product,
            :prefix => true 

  # => Model scopes
  scope :get_all, lambda { order('created_at asc') }
  scope :by_business_type, lambda {|business_type|where(["business_type=?",business_type])}
  scope :by_catalog,       lambda { where(["business_type = ?",'by_catalog']) }
  scope :by_mrp,       lambda { where(["business_type = ?",'by_mrp']) }
  scope :by_weight,       lambda { where(["business_type = ?",'by_weight']) }
  scope :by_bulk_weight,       lambda { where(["business_type = ?",'by_bulk_weight']) }
  scope :by_category_id, lambda {|cat_id|where(["category_id=?", cat_id])}
  scope :by_product_name, lambda {|product_name|where(["lower(name)=?", product_name.downcase])}
  scope :by_product_name_like, lambda {|product_name|where(["lower(name) LIKE ?", "%#{product_name.downcase}%"])}
  scope :by_product_id, lambda {|product_id|where(["id=?", product_id])}
  scope :set_id_in, lambda {|ids|where (["id in (?)", ids])}
  scope :thresh_hold_product, lambda { where(["thresh_hold > ?",'0']) }
  scope :like, lambda { |query|
   where(["name LIKE ?", "%#{query}%"])
  }
  scope :brand_like, lambda { |query|
   where(["lower(brand_name) LIKE ?", "%#{query.downcase}%"])
  }
  scope :set_product_brands, lambda {|product_brands|where(["brand_name in (?)",product_brands])}
  scope :not_conjugated_product, lambda {where(:conjugated_unit_id => nil)}
  scope :conjugated_product, -> { where('conjugated_unit_id IS NOT ?', nil) }
  scope :filter_by_itemcode_brand_mfr, lambda {|itemcode_brand_mfr| where(["lower(item_code) = :item_code OR lower(brand_name) = :brand_name OR lower(mfr_name) = :mfr_name",{item_code: itemcode_brand_mfr.downcase,brand_name: itemcode_brand_mfr.downcase, mfr_name: itemcode_brand_mfr.downcase}])}
  scope :by_brand_name, lambda {|brand_name|where(["brand_name=?", brand_name])}
  scope :set_product_id_in,  lambda {|product_ids|where(["id in (?)", product_ids])}
  scope :products_by_parent,  lambda {|parent_id|where(["parent = ?", parent_id])}
  scope :filter_by_product_id, lambda {|product_id|where(["products.id=?", product_id])}
  scope :combo_product, lambda{where(["product_type = ?",'combo']) }
  # scope :product_in_store, lambda {|product_id, store_id|where(["products.id = ? AND stores.id =?", product_id, store_id])}
  
  def self.product_in_store(product_id, store_id)
    joins("
      INNER JOIN store_products ON products.id =#{product_id} AND store_products.product_id=#{product_id} AND store_products.store_id=#{store_id}
    ")
  end

  # Adding virtual attributes in each object everywhere.
  def attributes
    VIRTUAL_ATTRIBUTES.each_with_object(super) { |a,h| h[a] = self.send(a) }
  end
  
  # Defining virtual attributes
  def sell_type
    self.business_type
  end

  def sell_type=(name)
    self.sell_type = self.business_type
  end

  def product_image
    self.properties.attribute_by_code('base_image')
  end

  def basic_unit
    self.measurement_unit.short_name
  end

  # def name
  #   if self.id.present?
  #     if self.package_component.present?
  #       self.package_component.name
  #     else
  #       # product_details = ActiveRecord::Base.connection.execute("select products.name as product_name from products where products.id = #{self.id}")
  #       product_details = ActiveRecord::Base.connection.execute("SELECT products.name as product_name from products WHERE products.id = #{self.id};")
  #       product_details.first['product_name']
  #     end
  #   else
  #     p = self
  #     p['name']
  #   end
  # end

  def product_name(_package_product)
    package_components = _package_product.name.split('-')
    package_component_id = package_components[2]
    _package_name = Package.find(package_components[0]).name
    _product_name = PackageComponent.find(package_component_id).name
    "#{_product_name} for #{_package_name}"
  end

  def product_basic_unit
    basic_unit
  end

  def physical_type
    _ptype = self.properties.attribute_by_code('physical_type_id')
    PhysicalType.find(_ptype)
  end

  # Handling method missing with
  # Product Attribute values
  def method_missing(method_name, *args, &block)
    # Check if method is an attribute or not
    _attr = self.properties.by_code(method_name).first
    if _attr.present?
      return _attr.value
    elsif self.product_attribute_set.present?
      # Check if method is an attribute key or not
      _key = self.product_attribute_set.product_attribute_keys.by_code(method_name).first
      if _key.present?
        if _key.select?
          _option = _key.default_options.first
          return _option.value if _option.present?
        else
          return _key.default_value
        end
      else
        super
      end
    else
      super
    end
  end
  
  # => Dynamic methods for product types
  PRODUCT_TYPE.each do |type|
    define_method "#{type}?" do
      self.product_type == type
    end
  end

  # => Dynamically defining these custom finder methods for product types
  class << self
    PRODUCT_TYPE.each do |type|
      define_method "#{type}" do
        where(["product_type=?", type])
      end
    end
  end

  
  # => Dynamic methods for Sell types
  BUSINESS_TYPE.each do |sell_type|
    define_method "#{sell_type}?" do
      self.business_type == sell_type
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    BUSINESS_TYPE.each do |sell_type|
      define_method "#{sell_type}" do
        where(["business_type=?", sell_type])
      end
    end
  end

  # => Model functions
  def update_image
    self['image_original'] = self.image(:original)
    
    self.image.styles.each do |format|
      self["image_#{format[0].to_s}"] = self.image(format[0].to_s)
    end
    
  end

  #Product searching
  def self.name_like(search)  
    if search  
      where('name LIKE ?', "%#{search}%")  
    else  
      all  
    end  
  end

  def self.product_for(prefix)
    products = where("lower(name) LIKE ?", "#{prefix.downcase}%")
    products.order("id desc").limit(10)
  end

  def self.set_category(cat)
    if cat.present?
      cat_ids = Category.get_all_subcategories(cat)
      where('category_id IN(?)',cat_ids)
    else
      all
    end
  end

  def self.product_not_in(_arr)
    where('id NOT IN(?)',_arr) 
  end

  def self.product_not_in_unit(_arr)
    where('product_id NOT IN(?)',_arr)
  end

  def self.check_stock_status(_store_id,stock_filter,unit_id)
    if stock_filter.present?
      _pro_arr = Array.new
      if stock_filter == "1" || stock_filter == "2"
        latest_stock_update_ids = StockUpdate.where(["store_id = ?", _store_id]).group(:product_id).maximum(:id).values
        _updates = StockUpdate.where(["id IN(?) and stock > 0", latest_stock_update_ids])
        _updates.each do |up|
          _pro_arr.push(up.product_id)
        end
        if stock_filter == "1"
          where('products.id IN(?)',_pro_arr)
        elsif stock_filter == "2"
          where('products.id NOT IN(?)',_pro_arr) 
        end
      elsif stock_filter == "3"
        _menu_products = MenuManagement::get_activated_menu_products(unit_id)
        _menu_products.each do |mp|
          _pro_arr.push(mp.product_id)
        end
        where('products.id IN(?)',_pro_arr)
      end
    else
      all
    end    
  end

  def self.check_product_stock_status(stock_filter,unit_id,current_user)
    if stock_filter.present?
      unit_ids = []
      store_ids = []
      unit_ids << current_user.unit.id
      current_user.unit.children.map { |e| unit_ids.push e.id } if current_user.unit.children.present?
      @stores = Store.set_unit_in(unit_ids).not_return.primary_secondery
      @stores.map { |e| store_ids.push e.id  }
      _pro_arr = Array.new
      if stock_filter == "1" || stock_filter == "2"
        latest_stock_update_ids = StockUpdate.group(:product_id).set_store_in(store_ids).maximum(:id).values
        _updates = StockUpdate.where(["id IN(?) and stock > 0", latest_stock_update_ids])
        _updates.each do |up|
          _pro_arr.push(up.product_id)
        end
        if stock_filter == "1"
          where('products.id IN(?)',_pro_arr)
        elsif stock_filter == "2"
          where('products.id NOT IN(?)',_pro_arr) 
        end
      elsif stock_filter == "3"
        _menu_products = MenuManagement::get_activated_menu_products(unit_id)
        _menu_products.each do |mp|
          _pro_arr.push(mp.product_id)
        end
        where('products.id IN(?)',_pro_arr)
      end
    else
      all
    end    
  end

  def self.get_related_product(product)
    _related_product_array = Array.new
    if product.subproducts.present?
      product.subproducts.each do |subproduct|
        _related_product_array.push subproduct.id
      end
    end
    if product.parentproduct.present?
      _related_product_array.push product.parentproduct.id
      if product.parentproduct.subproducts.present?
        product.parentproduct.subproducts.each do |subproduct|
        _related_product_array.push subproduct.id
      end
      end
    end
    return _related_product_array
  end 

  def self.filter_by_product_type(product_types)
    if !product_types.empty?
      where('product_type IN(?)',product_types)
    else
      all
    end    
  end

  def self.filter_by_string(searcing_text)
    if searcing_text.present?
      filter_text = searcing_text.downcase
      n = 1
      filter_text_length = filter_text.length
      for a in 1..filter_text_length do
        if a == 1        
          filter_text.insert a, "% "
        elsif a != filter_text_length
          n = n+3
          filter_text.insert n, "% "
        end
      end
      puts filter_text
      # where("lower(products.name) LIKE ?", "%#{searcing_text.downcase}%")
      where("lower(products.name) LIKE ? OR lower(products.name) LIKE ?", "%#{searcing_text.downcase}%", "#{filter_text}%")
    else
      all
    end    
  end

  def self.filter_by_item_code(searcing_text)
    if searcing_text.present?
      where("lower(products.item_code) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end    
  end  

  # def self.filter_by_itemcode_brand_mfr_new(searcing_text)
  #   if searcing_text.present?
  #     where("lower(item_code) = ? OR lower(brand_name) = ? OR lower(mfr_name) = ?", searcing_text, searcing_text, searcing_text)
  #     # where(["lower(item_code) = :item_code OR lower(brand_name) = :brand_name OR lower(mfr_name) = :mfr_name",{item_code: itemcode_brand_mfr.downcase,brand_name: itemcode_brand_mfr.downcase, mfr_name: itemcode_brand_mfr.downcase}])
  #   else
  #     all
  #   end
  # end

  def self.filter_by_brand_name(searcing_text)
    if searcing_text.present?
      where("lower(products.brand_name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end    
  end
  
  def self.filter_by_mfr_name(searcing_text)
    if searcing_text.present?
      where("lower(products.mfr_name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end    
  end  

  def self.filter_by_sku(products,sku,store_id)
    if sku.present?
      products.joins(:stocks).where("stocks.store_id = (?) AND stocks.sku LIKE (?)", "#{store_id}", "%#{sku}%").uniq
    end
  end

  def self.filter_by_product_category(product_categories)
    if !product_categories.empty?
      pro_cat_arr = Array.new
      product_categories.each do |product_category|
        pro_cat_arr = pro_cat_arr + Category.get_all_subcategories(product_category)
      end
      where('category_id IN(?)',pro_cat_arr)
    else
      all
    end    
  end

  def self.get_product_meta(product_id, meta_key)
    product_meta = ProductMetum.where(:product_id => product_id, :meta_key => meta_key).first
    if product_meta.present?
      return JSON.parse(product_meta.meta_value)
    end
  end

  # def self.stock_report_to_csv(store_id,products,from_datetime,to_datetime)
  #   puts store_id
  #   CSV.generate do |csv|
  #     csv << ["Product", "Opening Stock", "Stock on audit", "Consumed (Audits)", "Consumed (Orders)","Consumed (Transfers)", "Total Debit", "Stock Purchases", "Total Credit", "Closing Stock", "Current Stock"]
  #     products.each do |product|
  #       sd = Stock.get_stock_report(store_id, product.id, from_datetime, to_datetime)
  #       cs = StockUpdate.current_stock(store_id, product.id)
  #       csv << ["#{product.name}", "#{sd[:opening_stock]} #{product.basic_unit}", "#{sd[:initial_audit_stock]} #{product.basic_unit}","#{sd[:audit_consumption]} #{product.basic_unit}","#{sd[:order_consumption]} #{product.basic_unit}","#{sd[:transfer_consumption]} #{product.basic_unit}","#{sd[:total_debit]} #{product.basic_unit}", "#{sd[:total_purchase]} #{product.basic_unit}", "#{sd[:total_credit]} #{product.basic_unit}", "#{sd[:closing_stock]} #{product.basic_unit}", "#{cs} #{product.basic_unit}(#{sd[:current_stock_price]})"]
  #     end
  #   end
  # end

  def self.stock_report_to_csv(store_id,products,from_datetime,to_datetime,currency,unit_id)
    #puts store_id
    CSV.generate do |csv|
      preferences = ReportPreference.by_unit(unit_id).by_key('stock_summery_report_store_wise').first
      @pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["product","opening_stock","stock_on_aduit","consumed_for_audit","audit_cost","consumed_for_order","order_cost","credit_on_transfer","consumed_for_transfer","transfer_cost","total_debit","debit_cost","stock_purchase","purchase_cost","total_credit","credit_cost","closing_stock","current_stock","stock_value"]
      csv_header = Array.new
      csv_header.push("Product") if @pref.include?('product')
      csv_header.push("Basic Unit")
      csv_header.push("Opening Stock") if @pref.include?('opening_stock')
      csv_header.push("Stock on Audit") if @pref.include?('stock_on_aduit')
      csv_header.push("Consumed (Audits)") if @pref.include?('consumed_for_audit')
      csv_header.push("Cost of Audit (#{currency})") if @pref.include?('audit_cost')
      csv_header.push("Consumed (Orders)") if @pref.include?('consumed_for_order')
      csv_header.push("Cost of Order (#{currency})") if @pref.include?('order_cost')
      csv_header.push("Consumed (Transfers)") if @pref.include?('consumed_for_transfer')
      csv_header.push("Cost of Transfers (#{currency})") if @pref.include?('transfer_cost')
      csv_header.push("Total Debit") if @pref.include?('total_debit')
      csv_header.push("Cost of Debit (#{currency})") if @pref.include?('debit_cost')
      csv_header.push("Credit (Transfers)") if @pref.include?('credit_on_transfer')
      csv_header.push("Stock Purchases") if @pref.include?('stock_purchase')
      csv_header.push("Cost of Purchase (#{currency})") if @pref.include?('purchase_cost')
      csv_header.push("Total Credit") if @pref.include?('total_credit')
      csv_header.push("Cost of Credit (#{currency})") if @pref.include?('credit_cost')
      csv_header.push("Closing Stock") if @pref.include?('closing_stock')
      csv_header.push("Current Stock") if @pref.include?('current_stock')
      csv_header.push("Value of Stock (#{currency})") if @pref.include?('stock_value')
      csv << csv_header
      #csv << ["Product", "Opening Stock", "Consumed (Audits)", "Consumed (Orders)","Consumed (Transfers)", "Total Debit", "Stock Purchases", "Total Credit", "Closing Stock", "Current Stock","Value of Stock(#{currency})"]
      report_precision = AppConfiguration.get_config_value_of_report('report_precision').present? ? AppConfiguration.get_config_value_of_report('report_precision').to_i : 2
      stock_value_summery = 0
      transfer_cost_summery = 0
      credit_cost_summery = 0
      opening_stock_cost_summery = 0
      closing_stock_cost_summery = 0

      products.each do |product|
        sd = Stock.get_stock_report(store_id, product.id, from_datetime, to_datetime)
        cs = StockUpdate.current_stock(store_id, product.id)
        current_stock_price = sd[:current_stock_price].to_i

        stock_value_summery += sd[:current_stock_price].to_f
        transfer_cost_summery += sd[:transfer_consumption_price].to_f
        credit_cost_summery += sd[:total_credit_price].to_f
        if cs != 0
          opening_stock_cost_summery += ( sd[:current_stock_price].to_f / cs.to_f ) * sd[:opening_stock].to_f
          closing_stock_cost_summery += ( sd[:current_stock_price].to_f / cs.to_f ) * sd[:closing_stock].to_f
        end

        csv_product = Array.new
        csv_product.push(product.name) if @pref.include?('product')
        csv_product.push(product.basic_unit)
        csv_product.push(sd[:opening_stock]) if @pref.include?('opening_stock')
        csv_product.push(sd[:initial_audit_stock]) if @pref.include?('stock_on_aduit')
        csv_product.push(sd[:audit_consumption]) if @pref.include?('consumed_for_audit')
        csv_product.push(sd[:audit_consumption_price].to_f.round(2)) if @pref.include?('audit_cost')
        csv_product.push(sd[:order_consumption]) if @pref.include?('consumed_for_order')
        csv_product.push(sd[:order_consumption_price].to_f.round(2)) if @pref.include?('order_cost')
        csv_product.push(sd[:transfer_consumption]) if @pref.include?('consumed_for_transfer')
        csv_product.push(sd[:transfer_consumption_price].to_f.round(2)) if @pref.include?('transfer_cost')
        csv_product.push(sd[:total_debit]) if @pref.include?('total_debit')
        csv_product.push(sd[:total_debit_price].to_f.round(2)) if @pref.include?('debit_cost')
        csv_product.push(sd[:credit_on_transfer]) if @pref.include?('credit_on_transfer')
        csv_product.push(sd[:total_purchase]) if @pref.include?('stock_purchase')
        csv_product.push(sd[:total_purchase_price].to_f.round(2)) if @pref.include?('purchase_cost')
        csv_product.push(sd[:total_credit]) if @pref.include?('total_credit')
        csv_product.push(sd[:total_credit_price].to_f.round(2)) if @pref.include?('credit_cost')
        csv_product.push(sd[:closing_stock]) if @pref.include?('closing_stock')
        csv_product.push(cs) if @pref.include?('current_stock')
        csv_product.push(current_stock_price) if @pref.include?('stock_value')
        csv << csv_product
        #csv << ["#{product.name}", "#{sd[:opening_stock]}","#{sd[:audit_consumption]}","#{sd[:order_consumption]}","#{sd[:transfer_consumption]}","#{sd[:total_debit]}", "#{sd[:total_purchase]}", "#{sd[:total_credit]}", "#{sd[:closing_stock]}", "#{cs}", current_stock_price.round(2)]
      end
      csv << Array.new
      csv << ["Total Value of Stock", "Total Cost of Transfer", "Total Cost of Credit", "Total Opening Stock Cost", "Total Closing Stock Cost"]
      csv << [stock_value_summery, transfer_cost_summery, credit_cost_summery, opening_stock_cost_summery, closing_stock_cost_summery]
    end
  end
  
  def self.import(file)
    imported_products =Array.new
    data_errors = Array.new

    CSV.foreach(file.path, headers: true) do |row|
      size_array = Array.new
      color_array = Array.new
      product = Product.find_by_id(row["id"]) || Product.find_by_name(row["name"]) || Product.new
      #product.attributes = row.to_hash.slice(*Product.accessible_attributes)
      category = Category.find_or_create_by!(name: row["category"])|| Category.find_by_id(row["category"]) 
      basic_unit = ProductBasicUnit.find_or_create_by!(short_name: row["basic_unit"]) || ProductBasicUnit.find_by_id(row["basic_unit"])
      attribute_set = ProductAttributeSet.find_by_name(row["attribute_set"]) || ProductAttributeSet.find_by_id(row["attribute_set"])
      sku_key = ProductAttributeKey.find_by_attribute_code("sku")
      short_name_key = ProductAttributeKey.find_by_attribute_code("short_name")
      business_type_key = ProductAttributeKey.find_by_attribute_code("business_type")
      short_description_key = ProductAttributeKey.find_by_attribute_code("short_description")
      long_description_key = ProductAttributeKey.find_by_attribute_code("long_description")
      if row["sizes"].present?
        row["sizes"].split(",").each do |size|
          size.strip!
          size_hash = {}
          size = Size.find_or_create_by!(name: size)
          size_hash[:size_id] = size.id
          size_array.push size_hash
        end  
      end  
      if row["colors"].present?
        row["colors"].split(",").each do |color|
          color.strip!
          color_hash = {}
          color = Color.find_or_create_by!(name: color)
          color_hash[:color_id] = color.id
          color_array.push color_hash
        end  
      end  
      category_id = category.present? ? category.id : nil
      basic_unit_id = basic_unit.present? ? basic_unit.id : nil
      product_attribute_set_id = attribute_set.present? ? attribute_set.id : nil
      short_description = row["short_description"].present? ? row["short_description"]: ''
      long_description = row["long_description"].present? ? row["long_description"]: ''
      business_type = row["business_type"].present? ? row["business_type"]: ''
      short_name = row["short_name"].present? ? row["short_name"]: ''
      local_name = row["local_name"].present? ? row["local_name"]: ''
      if row["image"].present?
        #product.attributes = {:name=>row["name"], :category_id=>category_id, :basic_unit_id=>basic_unit_id,:product_attribute_set_id=>product_attribute_set_id, :business_type=>row["business_type"], :product_type=>row["product_type"], :local_name=>local_name, :hsn_code=>row["hsn_code"],:item_code=>row["item_code"],:brand_name=>row["brand_name"],:mfr_name=>row["mfr_name"], :product_sizes_attributes=>size_array, :color_products_attributes=>color_array, :properties_attributes=>{"#{Time.now.to_i}#{sku_key.id}"=>{:product_attribute_key_id=>sku_key.id,:value=>row["sku"]},"#{Time.now.to_i}#{short_name_key.id}"=>{:product_attribute_key_id=>short_name_key.id,:value=>short_name},"#{Time.now.to_i}#{business_type_key.id}"=>{:product_attribute_key_id=>business_type_key.id,:value=>business_type},"#{Time.now.to_i}#{short_description_key.id}"=>{:product_attribute_key_id=>short_description_key.id,:value=>short_description},"#{Time.now.to_i}#{long_description_key.id}"=>{:product_attribute_key_id=>long_description_key.id,:value=>long_description}}, :product_images_attributes=>{"#{Time.now.to_i}#{sku_key.id}"=>{:image=>URI.parse(row["image"])}}}
        product.attributes = {:name=>row["name"], :category_id=>category_id, :basic_unit_id=>basic_unit_id,:product_attribute_set_id=>product_attribute_set_id, :business_type=>row["business_type"], :product_type=>row["product_type"], :local_name=>local_name, :hsn_code=>row["hsn_code"],:item_code=>row["item_code"],:brand_name=>row["brand_name"],:mfr_name=>row["mfr_name"], :product_sizes_attributes=>size_array, :color_products_attributes=>color_array, :properties_attributes=>{"#{Time.now.to_i}#{sku_key.id}"=>{:product_attribute_key_id=>sku_key.id,:value=>row["sku"]},"#{Time.now.to_i}#{short_name_key.id}"=>{:product_attribute_key_id=>short_name_key.id,:value=>short_name},"#{Time.now.to_i}#{business_type_key.id}"=>{:product_attribute_key_id=>business_type_key.id,:value=>business_type},"#{Time.now.to_i}#{short_description_key.id}"=>{:product_attribute_key_id=>short_description_key.id,:value=>short_description},"#{Time.now.to_i}#{long_description_key.id}"=>{:product_attribute_key_id=>long_description_key.id,:value=>long_description}}}      
      else
        product.attributes = {:name=>row["name"], :category_id=>category_id, :basic_unit_id=>basic_unit_id,:product_attribute_set_id=>product_attribute_set_id, :business_type=>row["business_type"], :product_type=>row["product_type"], :local_name=>local_name, :hsn_code=>row["hsn_code"],:item_code=>row["item_code"],:brand_name=>row["brand_name"],:mfr_name=>row["mfr_name"], :product_sizes_attributes=>size_array, :color_products_attributes=>color_array, :properties_attributes=>{"#{Time.now.to_i}#{sku_key.id}"=>{:product_attribute_key_id=>sku_key.id,:value=>row["sku"]},"#{Time.now.to_i}#{short_name_key.id}"=>{:product_attribute_key_id=>short_name_key.id,:value=>short_name},"#{Time.now.to_i}#{business_type_key.id}"=>{:product_attribute_key_id=>business_type_key.id,:value=>business_type},"#{Time.now.to_i}#{short_description_key.id}"=>{:product_attribute_key_id=>short_description_key.id,:value=>short_description},"#{Time.now.to_i}#{long_description_key.id}"=>{:product_attribute_key_id=>long_description_key.id,:value=>long_description}}}
      end  
      imported_products.push product 
    end
    if imported_products.map(&:valid?).all?
      imported_products.each(&:save!)
      true
    else
      imported_products.each_with_index do |product, index|
        unless product.valid?
          errors_messages = self.error_messages_for(product)
          data_errors.push("Row #{index+2}: #{errors_messages}")
        end
      end
      error_str = data_errors.map { |e| e }.join(', ')
      raise "Data of #{data_errors.size} row(s) prevented the form being saved. #{error_str}"
    end
  end

  def self.get_inventory_compatible_qty raw_unit,raw_quantity,quantity
    _raw_pro_unit = ProductUnit.find(raw_unit)
    _inventry_equity_quantity = (_raw_pro_unit.multiplier.to_f)*(raw_quantity.to_f) #Generating the stock to consume
    _total_consumeable_qty = _inventry_equity_quantity * quantity
  end
  
  def self.save_product_compositions(product,raw_product_id,raw_product_quantity,raw_product_unit)
    _raw_pro_unit = ProductUnit.find(raw_product_unit)
    _raw_pro = Product.find(raw_product_id)
    _inventry_quantity = (_raw_pro_unit.multiplier.to_f)*(raw_product_quantity.to_f) #Generating the stock to consume
    _hash = { :raw_product_id  =>  raw_product_id,
              :raw_product_quantity => raw_product_quantity,
              :raw_product_unit => raw_product_unit,
              :inventory_quantity => _inventry_quantity,
              :basic_unit => _raw_pro.basic_unit}
    _new_composition = product.product_compositions.create(_hash)
  end

  def self.error_messages_for(*objects)
    error_string = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    error_string = errors.map { |e|  "#{e}" }.join(', ') if errors.any?
  end  

  private

  def set_attributes
    #_basic_unit = ProductBasicUnit.find(self.basic_unit_id)
    #self.basic_unit = _basic_unit.short_name
    if self.conjugated_unit_id.present?
      _conjugated_unit = ConjugatedUnit.find(self.conjugated_unit_id)
      self.conjugated_unit = _conjugated_unit.conjugated_name
    end
  end

  def generate_product_serial_code
    if self.p_code == nil or self.p_code == ''
      product_codes = Product.where("p_code is NOT NULL")
      if product_codes.present?
        product_codes = product_codes.pluck(:p_code)
        product_code_prefix = []
        product_codes.map { |code| product_code_prefix.push code.chars.first }
        product_code_prefix.sort_by!{ |code| code }
        largest_prefix = product_code_prefix.last
        next_prefix = largest_prefix == 'Z' ? "A" : largest_prefix.next!
        new_p_code_suffix = sprintf '%05d', self.id
        new_p_code = "#{next_prefix}#{new_p_code_suffix}"
      else
        new_p_code_suffix = sprintf '%05d', self.id
        new_p_code = "A#{new_p_code_suffix}"
      end
      self.update_column(:p_code, new_p_code)
    end
  end

end
