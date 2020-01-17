class ResourceOrderHistoryDetail < ActiveRecord::Base
  attr_accessible :menu_product_id, :product_id, :product_name, :recorded_at, :remarks, :unit_id, :user_id, :resource_id, :quantity, :resource_id, :hsn_code, :store_id

  validates :menu_product_id, :presence => true
  validates :quantity, :presence => true

  belongs_to :resource
  belongs_to :unit
  belongs_to :user
  belongs_to :menu_product
  belongs_to :resource_order_history

  after_create  :set_attributes

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('hsn_code')
        if self.menu_product.product.hsn_code.present?
          self.hsn_code = self.menu_product.product.hsn_code
        else
          self.hsn_code = ''
        end 
      end  
      self.product_id = self.menu_product.product_id
      self.product_name = self.menu_product.product_name
    end
  end

  def set_attributes
  	self.update_attributes(:unit_id => self.resource_order_history.unit_id, :user_id => self.resource_order_history.user_id, :resource_id => self.resource_order_history.resource_id, :recorded_at => self.resource_order_history.recorded_at)
  end
end
