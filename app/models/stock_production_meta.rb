class StockProductionMeta < ActiveRecord::Base
  attr_accessible :ingredients, :store_id, :product_id, :production_quantity, :price, :stock_production_id

  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  # => Model relations
  has_many :stock_production_raws
  has_many :stock_production_meta_processes
  belongs_to :stock_production
  belongs_to :product
  belongs_to :store

  # => Model callbacks
  after_create :create_stock_production_raws, on: :create
  after_create :create_stock_production_meta_processes, on: :create
  
  # => Model Validations
  validates :product_id,          :presence => true
  validates :store_id,            :presence => true
  validates :price,               :presence => true
  validates :production_quantity, :presence => true

  #Model Scopes
  scope :set_store,   lambda {|store|where(["store_id=?", store])}
  scope :set_product, lambda {|pro|where(["product_id=?", pro])}
  
  private

  def create_stock_production_raws
    _sub_pros = JSON.parse(self.ingredients)
    _sub_pros.each do |sp|
      _raw_product_current_stock = number_with_precision(get_product_current_stock(self.store_id, sp['raw_product_id']), :precision => 8, :significant => true, :strip_insignificant_zeros => true).to_f
      - product_current_stock_cost = get_product_current_stock_cost(self.store_id, sp['raw_product_id'])
      _raw_product_current_stock_cost = number_to_currency(product_current_stock_cost.present? ? product_current_stock_cost.current_price.to_f : 0, unit: '').to_f
      _raw_product_quantity = sp['raw_product_quantity'].to_f
      _raw_product_cost = (_raw_product_current_stock_cost /_raw_product_current_stock) * _raw_product_quantity
      
      _raw_entry = StockProductionRaw.new(:product_id=>sp['raw_product_id'], :quantity=>sp['raw_product_quantity'], :target_product_id=>self.product_id, :store_id=>self.stock_production.store_id, :product_cost=>_raw_product_cost.to_f.round(2))
      self.stock_production_raws << _raw_entry
    end
  end

  def create_stock_production_meta_processes
    _process_compositions = ProcessComposition.by_product_id(self.product_id)
    _process_compositions.each do |pc|
      _process_cost = pc.production_process.cost * pc.duration.to_i * self.production_quantity
      
      _meta_process_entry = StockProductionMetaProcess.new(:target_product_id=>self.product_id, :production_process_id=>pc.production_process_id, :production_process_duration=>pc.duration * self.production_quantity, :status=>"initialize", :process_cost => _process_cost.to_f.round(2))
      self.stock_production_meta_processes << _meta_process_entry
    end
  end

end
