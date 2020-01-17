json.extract! question_unit.question, :id, :title, :question_type, :image, :option_type, :status
json.options question_unit.question.options do |option|
	json.extract! option, :id, :title, :image
end