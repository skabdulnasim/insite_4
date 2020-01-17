class KitchenProductionAudit < ActiveRecord::Base
  attr_accessible :procured_qty, :product_id, :received_qty, :remarks, :status, :stock_transfer_id, :store_id, :audit_id
  
  # => Defining relations
  belongs_to :store
  belongs_to :product
  belongs_to :stock_transfer

  # => Model validations
  validates :product_id, :presence => true
  validates :store_id, :presence => true
  validates :stock_transfer_id, :presence => true
  validates :status, :presence => true
  validates :received_qty, :presence => true

  # => Model Scopes
  scope :not_audited, lambda { where(:status => '1') }
  scope :audit_not_approved, lambda { where(:status => '2') }
  scope :unique_audits, ->{select("DISTINCT audit_id").where("audit_id <> (?)","")}
  scope :set_audit, ->{select("DISTINCT audit_id").where("audit_id <> (?)","")}
  scope :set_audit_id, lambda {|a_id|where(["audit_id=?", a_id])}

  
  def self.initiate_kitchen_production_audit(stock_transfer_id,store_id,product_id,received_qty)
    _audit = KitchenProductionAudit.create(:stock_transfer_id => stock_transfer_id, :store_id => store_id,:product_id => product_id,:received_qty=>received_qty,:status=>"1")
    return _audit
  end
end
