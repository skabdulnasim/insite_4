class Bit < ActiveRecord::Base
  attr_accessible :area_descriptions, :name, :parent_bit
  has_many :user_bits, dependent: :destroy
  has_many :resources, through: :bit_resources
  has_many :bit_resources, dependent: :destroy
  belongs_to :zone
  scope :not_allocated_in_zone, lambda{where(["zone_id IS NULL"])}
  scope :by_bit_name,    lambda { |bit_name| where(["lower(name) = ?",bit_name.downcase]) }
  scope :by_unit_id, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_unit_list, lambda{|unit_arr|where(["unit_id IN(?)",unit_arr])}
  def self.bit_name_like(searcing_text)
    puts searcing_text
    if searcing_text.present?
      where("lower(name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end
  end
	def self.save_bit_to_zone(zone_id,bit_ids)
		puts zone_id
		puts bit_ids.class
		bit_ids.each do |bit_id|
			Bit.where("id=?",bit_id).first.update_attribute(:zone_id,zone_id)
		end
		return true
	end
  def self.update_bit_for_zone(old_bits,new_bits,zone_id)
    old_bits.each do |old_bit|
      Bit.find(old_bit).update_attribute(:zone_id,nil)
    end
    new_bits.each do |new_bit|
      Bit.find(new_bit).update_attribute(:zone_id,zone_id)
    end
  end
end
