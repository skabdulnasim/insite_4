module PrintersHelper
  def is_checked_model_data_assignable(model_data,assignable_id)
    return model_data.to_i == assignable_id.to_i && params[:model_name] == @printer.assignable_type
  end
end
