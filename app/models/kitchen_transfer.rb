class KitchenTransfer < ActiveRecord::Base
  attr_accessible :from_store, :kitchen_transfers_transaction_id, :product_id, :status, :status_log, :stock_credit, :transaction_id, :activity_id
end
