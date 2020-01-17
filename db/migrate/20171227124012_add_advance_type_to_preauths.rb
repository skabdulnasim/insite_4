class AddAdvanceTypeToPreauths < ActiveRecord::Migration
  def change
    add_column :preauths, :advance_id, :integer
    add_column :preauths, :advance_type, :string
  end
end
