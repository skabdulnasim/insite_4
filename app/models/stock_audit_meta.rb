class StockAuditMeta < ActiveRecord::Base
  attr_accessible :counted_stock, :current_stock, :delta_stock, :product_id, :stock_audit_id, :remarks, :audit_options, :stock_consumed, :current_stock_at_review, :stock_added, :sku, :stock_id, :model_no, :batch_no, :size_id, :color_id, :stock_identity,:reason_code
  
  belongs_to :stock_audit
  belongs_to :product
  belongs_to :color
  belongs_to :size

  # => Model validations
  validates :stock_audit_id, :presence => true
  validates :product_id, :presence => true

  # Model callback
  after_create :create_notification
  scope :get_audit_in,          lambda {|audit_ids|where(["stock_audit_id in (?)", audit_ids])}
  
  def self.by_date(from_date, upto_date)
    if from_date.present? && upto_date.present?
      where('created_at BETWEEN ? AND ?',from_date,upto_date)
    else
      all
    end
  end

  def create_notification
    puts self.inspect
    puts self.product.inspect
    if AppConfiguration.get_config_value('threshold_audit_alert') == 'enabled'
      puts self.product.inspect
    end  
  end
end
