class AddLastUpdatedAtCommissionRules < ActiveRecord::Migration
  def change
    add_column :commission_rules, :recorded_at, :datetime
  end
end
