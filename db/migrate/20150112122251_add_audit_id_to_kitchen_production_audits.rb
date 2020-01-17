class AddAuditIdToKitchenProductionAudits < ActiveRecord::Migration
  def change
    add_column :kitchen_production_audits, :audit_id, :string
  end
end
