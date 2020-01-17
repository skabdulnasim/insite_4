class BitResource < ActiveRecord::Base
  attr_accessible :bit_id, :resource_id, :status
  belongs_to :bit
  belongs_to :resource
  def self.save_bit_resources(bit_id,resources)
    puts "resource_id class is #{resources.class}"
    resources = resources.split(",")
  	prev = self.where("bit_id=?",bit_id)
  	prev.destroy_all if prev.present?
  	resources.each do |resource|
      self.create(:bit_id=>bit_id, :resource_id=>resource)
  	end
  end
end
