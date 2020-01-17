class DestinationStoreValueMigrated < ActiveRecord::Migration
  def up
  	_requistions = StoreRequisition.all
  	_requistions.each do |r|
  		puts r.inspect
  		r.update_column(:to_store_id,r.to_store)
  	end	
  end
end
