class InsertDefaultValueToQuestion < ActiveRecord::Migration
  def up
  	Question.create(:title => "Default", :question_type => "Inspection", :option_type => "Input", :status => "enable")
  	QuestionUnit.create(:question_id => 1, :unit_id => 3)
  end
end
