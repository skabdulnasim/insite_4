class AddOptionTypeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :option_type, :string
  end
end
