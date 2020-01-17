class RenameColunAnwerToAsnwer < ActiveRecord::Migration
  def up
  	rename_column :inspection_question_asnwers, :anwer, :answer
  end
end
