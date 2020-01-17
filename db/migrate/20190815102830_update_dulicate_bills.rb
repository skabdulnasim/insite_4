class UpdateDulicateBills < ActiveRecord::Migration
  def up
  	serails = Bill.select('serial_no').group('serial_no').having("count(serial_no)>1")
  	serails.each do |serail|
  		bills = Bill.where('serial_no=?',serail['serial_no'])
  		i = 0
  		bills.each do |bill|
  			if i > 0
  				serial_no = "#{bill.serial_no}-#{i}"
  				puts bill.inspect
  				bill.update_column(:serial_no, serial_no)
  			end	
  			i = i+1
  		end	
  	end	
  end
end
