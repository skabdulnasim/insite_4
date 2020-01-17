class StockTransferTemplateProduct < ActiveRecord::Base
  attr_accessible :product_id, :quantity, :stock_transfer_template_id
  # => Model relations
  belongs_to :product
  belongs_to :stock_transfer_template

  # => Model validations
  validates :product_id,                  :presence => true
  validates :stock_transfer_template_id,  :presence => true
  validates :quantity,                    :presence => true
end
