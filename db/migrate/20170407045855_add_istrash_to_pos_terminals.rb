class AddIstrashToPosTerminals < ActiveRecord::Migration
  def change
  	unless column_exists? :pos_terminals, :istrash
    	add_column :pos_terminals, :istrash, :integer
    end	
  end
end
