class AddAuditSerialNoToAudit < ActiveRecord::Migration
  def change
    add_column :audits, :audit_serial_no, :text
  end
end
