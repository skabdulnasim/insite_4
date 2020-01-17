class Store < ActiveRecord::Base
  attr_accessible :address, :contact_number, :name, :pincode, :store_image, :store_type, :unit_id, :store_priority, :tin_no, :tan_no, :latitude, :longitude, :gstn_no, :pan_no, :contact_person, :user_id

  # => Defining Relations
  has_many :stocks
  has_many :stock_updates
  has_many :stock_purchases
  has_many :purchase_orders
  has_many :store_requisitions
  has_many :store_requisition_logs
  has_many :stock_transfer_templates
  has_many :stock_credit_transfers, :class_name => "StockTransfer", :foreign_key => "secondary_store_id"
  has_many :stock_debit_transfers, :class_name => "StockTransfer", :foreign_key => "primary_store_id"
  has_many :sent_requisitions, :class_name => "StoreRequisitionLog", :foreign_key => "from_store_id"
  has_many :kitchen_productions, :class_name => "StockProduction", :foreign_key => "kitchen_store_id"
  #has_many :store_requisitions, :class_name => "StoreRequisition", :foreign_key => "store_id"
  #has_many :store_requisitions, :class_name => "StoreRequisition", :foreign_key => "to_store_id"
  has_many :kitchen_production_audits
  has_many :stock_productions
  has_many :stock_audits
  has_many :printers, as: :assignable
  belongs_to :unit
  belongs_to :user
  has_many :store_products
  has_many :products, :through => :store_products
  has_many :simos
  has_many :return_items
  has_many :smart_pos
  has_many :store_racks
  has_many :boxings
  before_validation :set_attributes 
  has_many :warehouse_meta ,dependent: :destroy
  has_many :order_details
  has_many :orders
  # => Model Validations
  validates :name,          :presence => true,
                            :length => { :maximum => 100 }
  validates :store_type,    :presence => true,
                            :length => { :maximum => 200 }
  validates :store_priority,:presence =>true
  validate  :store_priority_unique #Custom validation

  # => Model Scopes
  scope :by_pincode, lambda{|pincode|where(["pincode=?", pincode])}
  scope :unit_stores, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :set_unit_in, lambda {|unit_ids|where(["unit_id in (?)", unit_ids])}
  scope :store_id_not, lambda {|id|where(["id !=?", id])}
  scope :physical, lambda {where(:store_type => 'physical_store')}
  scope :virtual, lambda {where(:store_type => 'virtual_store')}
  scope :kitchen, lambda {where(:store_type => 'kitchen_store')}
  scope :primary, lambda {where(:store_priority => 'primary_store')}
  scope :secondary, lambda {where(:store_priority => 'secondary_store')}  
  scope :primary_secondery, lambda {where("store_priority IN ('primary_store','secondary_store')")}
  scope :by_store_type, lambda {|store_type| where(["store_type = ?",store_type])}    
  scope :not_return,  lambda { where("store_type NOT IN ('return_store')")}
  scope :return_store, lambda {where(:store_type => 'return_store')}
  scope :set_id_in,       lambda {|store_ids|where(["id in (?)", store_ids])}
  scope :waste_bin, lambda {where(:store_type => 'waste_bin')}
  # => Custom Validation callback action
  def store_priority_unique
    if self.store_priority == "primary_store"
      primary_store = Store.where(:unit_id => self.unit_id, :store_priority => 'primary_store').first
        if primary_store.present?
          self.store_priority = 'secondary_store'
        end
    end
  end

  def self.by_transfer_type type, store_id, unit_id
    if type == 'to_other_store'
      if AppConfiguration.get_config_value('stock_transfer_to_secondary_store') == "enabled"
        store_id_not(store_id).physical.primary_secondery
      else  
        store_id_not(store_id).physical.primary
      end  
    elsif type == 'to_own_store'
      store_id_not(store_id).unit_stores(unit_id).physical
    elsif type == 'to_production_store'
      # store_id_not(store_id).unit_stores(unit_id).kitchen
      store_id_not(store_id).kitchen
    elsif type == 'to_waste_bin'
      # store_id_not(store_id).unit_stores(unit_id).waste_bin
      store_id_not(store_id).waste_bin
    end
  end 

  def set_attributes
    if new_record?
      if self.address.present?
        self.address = self.unit.address
      end
    end
  end
  end
