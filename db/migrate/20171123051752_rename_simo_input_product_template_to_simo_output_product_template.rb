class RenameSimoInputProductTemplateToSimoOutputProductTemplate < ActiveRecord::Migration
  def up
  	rename_table :simo_input_product_templates, :simo_output_product_templates
  end

  def down
  	rename_table :simo_output_product_templates, :simo_input_product_templates
  end
end
