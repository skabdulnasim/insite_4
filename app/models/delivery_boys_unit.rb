class DeliveryBoysUnit < ActiveRecord::Base
  belongs_to :delivery_boy
  belongs_to :unit
  attr_accessible :account_id,:unit_id,:delivery_boy_id

  def self.save_assign_unit(unit_ids,delivery_boy_id)
    DeliveryBoysUnit.where("delivery_boy_id =(?)",delivery_boy_id).destroy_all
    unit_ids.each do |unit_id|
      unit_id,account_id = unit_id.split(",")
      @assign_unit = DeliveryBoysUnit.new(:account_id => account_id ,:unit_id => unit_id, :delivery_boy_id => delivery_boy_id)
      @assign_unit.save
    end
    return @assign_unit
  end
end
