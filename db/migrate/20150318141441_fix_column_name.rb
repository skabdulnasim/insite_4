class FixColumnName < ActiveRecord::Migration
	def up
		rename_column	:payments, :paymentmod_id, :paymentmode_id
		rename_column	:payments, :paymentmod_type, :paymentmode_type
		rename_column	:settlements, :user_id, :client_id
	end

  def down
  end
end
