class AddImageToDenomination < ActiveRecord::Migration
  def change
  	add_attachment :denominations, :image
  end
end