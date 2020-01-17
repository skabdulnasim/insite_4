if @error.present?
  json.data Hash.new
else
  json.data do 
    json.inspection @inspection
    json.inspection_questions @inspection.inspection_questions do |i_q|
      json.extract! i_q, :id, :question_title
      json.inspection_question_image i_q.question.image
      if i_q.question.question_type != "Input"
        json.inspection_question_options i_q.question.options do |i_q_o|
        json.extract! i_q_o, :title, :image
        end
      end
      json.inspection_question_asnwers i_q.inspection_question_asnwers do |i_q_a|
        json.extract! i_q_a, :answer, :id
        json.answer_option_image i_q_a.option.image if i_q_a.option.present?
      end
      json.inspection_question_images i_q.inspection_question_images do |i_q_i|
      # json.extract! i_q_i, :image
      json.image i_q_i.image.url(:original)
        json.id i_q_i.id
      end
    end
  end
end