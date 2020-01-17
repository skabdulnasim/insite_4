module ReportsHelper
  def get_data_type(selector)
    _model_class   =   selector.split('.').first.classify.constantize
    _col_name      =   selector.split('.').second
    _model_class.columns_hash[_col_name].type.to_s
  end

  def get_cb_agg_name(agg_fn,field)
    "#{agg_fn}(#{field})"
  end

  def is_checked_agg_cb(agg_fn,field)
    (@report.aggregation_functions || '').include?get_cb_agg_name(agg_fn,field)
  end
  def check_field(model_name,field_name)
    return model_name.where('\'#{field_name}\' IS NOT NULL').select(field_name)
    # _attribute_validation = _model_name.where('\'#{_field_value}\' IS NOT NULL').select(_field_value)
  end
  def replace_string_char(value)
    return value.gsub( ',', '_' ).gsub('.','_').gsub('(','_Of_All_').gsub(')','')
  end
end
