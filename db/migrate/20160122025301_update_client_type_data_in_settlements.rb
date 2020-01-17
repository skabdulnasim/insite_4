class UpdateClientTypeDataInSettlements < ActiveRecord::Migration
  def up
    Settlement.find_each do |settlement|
      settlement.update_attributes(:client_type => settlement.client_type.camelize)
    end
  end

  def down
  end
end
