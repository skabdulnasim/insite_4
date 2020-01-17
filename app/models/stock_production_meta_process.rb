class StockProductionMetaProcess < ActiveRecord::Base
  attr_accessible :production_process_duration, :production_process_id, :status, :stock_production_meta_id, :target_product_id, :actual_start_time, :actual_end_time, :expected_end_time, :process_width, :process_cost

  # => Model relations
  belongs_to :stock_production_meta
  belongs_to :target_product, class_name: "Product", foreign_key: "target_product_id"
  belongs_to :production_process

  # => Model callbacks
  after_create :update_cost_in_stock_production_meta

  # => Model Scopes
  scope :set_process_composition, lambda{|product_id,production_process_id| where (["product_id = ? and production_process_id = ?",product_id,production_process_id])}

  private

  def update_cost_in_stock_production_meta
  	_total_process_cost = StockProductionMetaProcess.where('stock_production_meta_id =? and target_product_id =?', self.stock_production_meta_id,self.target_product_id).sum(:process_cost)
	_total_product_cost = StockProductionRaw.where('stock_production_meta_id =? and target_product_id =?', self.stock_production_meta_id,self.target_product_id).sum(:product_cost)
	_total_cost = _total_process_cost + _total_product_cost
	StockProductionMeta.find_by_id_and_product_id(self.stock_production_meta_id,self.target_product_id).update_attributes( :price => _total_cost )  	
  end

end