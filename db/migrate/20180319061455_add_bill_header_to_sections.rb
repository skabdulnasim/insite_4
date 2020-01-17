class AddBillHeaderToSections < ActiveRecord::Migration
  def change
    add_column :sections, :bill_header, :text
    add_column :sections, :bill_footer, :text
  end
end
