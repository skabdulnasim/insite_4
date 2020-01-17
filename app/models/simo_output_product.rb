class SimoOutputProduct < ActiveRecord::Base
  attr_accessible :basic_unit_id, :product_id, :expected_quantity, :actual_quantity, :simo_id, :simo_input_product_id, :price, :total_weight
  belongs_to :simo_input_product
  belongs_to :product

  # after_update :credit_stock,
  after_update  :calculate_wastage	

  # def credit_stock
  # 	_recvd_stock = Stock.save_stock(self.product_id,self.simo_input_product.simo.store_id,self.price,self.actual_quantity,self.simo_input_product_id,"simo_input_product",self.actual_quantity,0,nil,nil,nil)
  # end

  def calculate_wastage
  	self.simo_input_product.update_wastage
  end
end