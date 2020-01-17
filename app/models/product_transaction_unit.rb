class ProductTransactionUnit < ActiveRecord::Base
  attr_accessible :basic_unit_id, :basic_unit_multiplier, :product_id, :product_unit_id, :product_unit_name, :transaction_type, :status

  belongs_to :product
  belongs_to :product_unit
  belongs_to :product_basic_unit, class_name: "ProductBasicUnit", foreign_key: :basic_unit_id
  # => Defining Bill statuses
  TYPE = %w(input output)
  
  # => Dynamic methods for transaction types
  TYPE.each do |type|
    define_method "#{type}?" do
      self.transaction_type == type
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    TYPE.each do |type|
      define_method "#{type}" do
        where(["transaction_type=?", type])
      end
    end
  end 
  
  validates :basic_unit_id,         :presence => true
  validates :basic_unit_multiplier, :presence => true
  validates :product_id,            :presence => true
  validates :product_unit_id,       :presence => true
  validates :product_unit_name,     :presence => true
  validates :transaction_type,      :presence => true

  scope :by_unit_id, lambda {|id|where(["product_unit_id = ?",id])}
  scope :by_unit_id_list, lambda {|unit_list|where(["product_unit_id IN(?)",unit_list])}
  scope :active_only, lambda{where(["status=?",true])}

  def self.create_for product, type, product_unit_id,multiplier
    unit = ProductTransactionUnit.new
    unit.set_attributes_for product, type, product_unit_id,multiplier
    unit.save!
    unit
  end
  def self.update_for transaction_unit_obj,basic_unit_multiplier
    product_unit = ProductUnit.find(transaction_unit_obj.product_unit_id)
    multiplier = basic_unit_multiplier.present? ? basic_unit_multiplier : product_unit.multiplier
    transaction_unit_obj.update_attributes(:basic_unit_multiplier=>multiplier,:status=>true)
  end
  def set_attributes_for product, type, product_unit_id,multiplier
    product_unit = ProductUnit.find(product_unit_id)
    self.basic_unit_id = product.basic_unit_id
    self.basic_unit_multiplier = multiplier.present? ? multiplier : product_unit.multiplier
    self.product_id = product.id
    self.product_unit_id = product_unit.id
    self.product_unit_name = product_unit.short_name
    self.transaction_type = type
    self.status =true
  end
end
