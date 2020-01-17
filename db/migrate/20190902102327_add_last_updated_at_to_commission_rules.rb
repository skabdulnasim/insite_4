class AddLastUpdatedAtToCommissionRules < ActiveRecord::Migration
  def change
    add_column :commission_rules, :last_updated_at, :datetime
  end
end
