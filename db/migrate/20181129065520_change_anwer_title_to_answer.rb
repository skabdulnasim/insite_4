class ChangeAnwerTitleToAnswer < ActiveRecord::Migration
  def up
  	rename_column :inspection_question_asnwers, :anwer_title, :anwer
  	add_column :inspections, :purpose, :text
  end
end
