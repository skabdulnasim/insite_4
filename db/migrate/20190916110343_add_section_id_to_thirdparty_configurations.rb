class AddSectionIdToThirdpartyConfigurations < ActiveRecord::Migration
  def change
    add_column :thirdparty_configurations, :section_id, :integer
  end
end
