class AddStatusToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :status, :string, :default => "enable"
  end
end
