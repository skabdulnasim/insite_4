class UpdateInspection < ActiveRecord::Migration
  def up
  	_ispections = Inspection.all
  	_ispections.each do |ins|
  		puts ins.resource_id
  		ins.update_attributes(:inspected_entity_id => ins.resource_id, :inspected_entity_type => 'Resource')
  	end
  end
end
