class AddAttributeIdToTermAttributes < ActiveRecord::Migration
  def change
    add_column :term_attributes, :attribute_id, :integer
  end
end
