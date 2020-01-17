class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.integer :audit_stock_id
      t.float :audit_stock
      t.integer :audit_status
      t.text :remark

      t.timestamps
    end
  end
end
