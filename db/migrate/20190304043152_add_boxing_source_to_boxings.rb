class AddBoxingSourceToBoxings < ActiveRecord::Migration
  def change
    add_column :boxings, :boxing_source_type, :string
    add_column :boxings, :boxing_source_id, :integer
  end
end
