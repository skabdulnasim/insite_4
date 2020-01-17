class MigrateVisitInspection < ActiveRecord::Migration
  def up
  	v_histories = VisitingHistory.where("resource_id IS NOT NULL")
  	v_histories.each do |vh|
  		puts vh.inspect
  		vh.update_attributes(:visited_entity_id => vh.resource_id, :visited_entity_type => 'Resource')
  		puts "VisitingHistory"
  	end	
  	inspections = Inspection.where("resource_id IS NOT NULL")
  	inspections.each do |ins|
  		puts "inspection"
  		puts ins.inspect
  		ins.update_attributes(:inspected_entity_id => ins.resource_id, :inspected_entity_type => 'Resource')
  	end	
  end
end
