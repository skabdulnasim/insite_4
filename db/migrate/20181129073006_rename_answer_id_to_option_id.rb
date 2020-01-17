class RenameAnswerIdToOptionId < ActiveRecord::Migration
  def up
  	rename_column :inspection_question_asnwers, :answer_id, :option_id
  end
end
