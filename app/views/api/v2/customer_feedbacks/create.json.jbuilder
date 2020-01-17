json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_customer_feedback)
  json.internal_message I18n.t(:success_customer_feedback)
  json.internal_message @validation_errors if @validation_errors.present?
  json.internal_message @error.message if @error.present?
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
  json.data do
    json.extract! @customer_feedback, :id, :email, :name, :phone, :unit_id
    json.feedback_answers @customer_feedback.customer_feedback_answers do |feedback_answer|
      json.feedback feedback_answer.feedback.title
      json.feedback_option feedback_answer.feedback_option.option_title
    end
  end  
end