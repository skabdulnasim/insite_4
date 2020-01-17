class StockTransferTemplate < ActiveRecord::Base
  attr_accessible :store_id, :template_name, :template_type, :user_id

  # => Model relations
  belongs_to :user
  belongs_to :store
  has_many :stock_transfer_template_products

  # => Model validations
  validates :template_name, :presence => true,
                            :length   => { :maximum => 50 }
  validates :template_type, :presence => true
  validates :store_id,      :presence => true
  validates :user_id,       :presence => true 

  TEMPLATE_TYPES = %w(trans_to_oth trans_to_own transfer_to_kitchen)

  # => Dynamic methods for template types
  TEMPLATE_TYPES.each do |type|
    define_method "#{type}?" do
      self.type == type
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    TEMPLATE_TYPES.each do |type|
      define_method "#{type}" do
        where(["type=?", type])
      end
    end
  end

  scope :set_type, lambda {|type|where(["template_type=?", type])}

  # => Function to save store to store transfer template
  def self.save_new_store_template(_selected_products,_template_name,_store_id,_transfer_type,_user_id)
    _new_template = StockTransferTemplate.create(:template_name=>_template_name, :store_id=>_store_id, :user_id=>_user_id, :template_type=>_transfer_type)
    if _new_template
      _selected_products.each do |sp|
        _temp_product = StockTransferTemplateProduct.create(:stock_transfer_template_id=>_new_template.id, :product_id=>sp[1][:product_id], :quantity=>sp[1][:transfer_qty])
      end
    end
  end

  # => Function to save store to store transfer template
  def self.save_new_kitchen_template(_selected_products,_template_name,_store_id,_transfer_type,_user_id)
    _new_template = StockTransferTemplate.create(:template_name=>_template_name, :store_id=>_store_id, :user_id=>_user_id, :template_type=>_transfer_type)
    if _new_template
      _selected_products.each do |sp|
        _temp_product = StockTransferTemplateProduct.create(:stock_transfer_template_id=>_new_template.id, :product_id=>sp[1][:menu_product_id], :quantity=>sp[1][:menu_product_qty])
      end
    end
  end
end