class AddAttachmentColumnToCustomerState < ActiveRecord::Migration
	def change
  	add_attachment :customer_states, :icon
	end
end
