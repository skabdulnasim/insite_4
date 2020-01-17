module KitchenManagement
  #get a transaction details (Primary store to kitchen)
  def self.get_store_transaction_details(tran_id)
    _tran = KitchenTransfer.where("transaction_id =? and activity_id =?",tran_id,1).first
    return _tran
  end
  #Getting stock details of a product for a store
  def self.get_kitchen_product_stocks(product_id,kitchen_id)
    _kitchen_transfer_credit_count = KitchenTransfer.where("kitchen_store_id =? and product_id=? and activity_id=?", kitchen_id,product_id,1).sum(:stock_credit)
    _kitchen_production_debit_count = KitchenTransfer.where("kitchen_store_id =? and product_id=? and activity_id=?", kitchen_id,product_id,2).sum(:stock_debit)
    
    _total_credit = _kitchen_transfer_credit_count - _kitchen_production_debit_count
    return _total_credit
  end 
end