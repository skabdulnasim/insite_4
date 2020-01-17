class PurchaseOrder < ActiveRecord::Base
  attr_accessible :mode, :name, :purchase_order_code, :recurring, :store_id, :unit_id, :user_id, :valid_from, :valid_till, :vendor_id, :business_type, :status, :purchase_order_metum_attributes, :smart_po_id

  after_create :purchase_order_approvals, if: :is_purchase_order_approval?

  has_many :purchase_order_metum, :dependent => :destroy
  has_many :stock_purchases
  belongs_to :vendor
  belongs_to :store
  belongs_to :unit
  belongs_to :user
  has_many :approvals, as: :approvable

  accepts_nested_attributes_for :purchase_order_metum

  # => Model Validations
  validates :name, :presence => true,
                   :length => { :maximum => 100 }
  validates :vendor_id, :presence => true
  #Model Scope
  scope :valid_till,  lambda { where(["valid_till >=?", Date.today]) }
  scope :stores_in, lambda {|store_ids|where(["store_id in (?)", store_ids])}
  scope :by_vendor, lambda {|vendor_id| where(["vendor_id=?", vendor_id])}
  scope :vendor_name_like, lambda {|vendor_name| joins(:vendor).merge(Vendor.vendor_like(vendor_name))}
  scope :set_ids_in, lambda {|ids|where(["purchase_orders.id in (?)", ids])}


  def purchase_order_approvals
    _all_roles = Role.all
    _all_roles.each do |role|
      if AppConfiguration.get_config_value("#{role.name}_purchase_order_approval") == "enabled"
        Approval.create([{:approvable_id => self.id, :approvable_type => "PurchaseOrder", :is_approve => "false", :role_id => role.id}])
      end
    end
  end

  def is_purchase_order_approval?
    key = (AppConfiguration.get_config_value('purchase_order_approval') == 'enabled') ? true : false
  end

end
