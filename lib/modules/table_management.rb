module TableManagement
  def self.update_table_state(_table_id,_user_id,_outlet_id,_state_id)
    _new_log = TableStatusLog.new
    _new_log[:outlet_id]        = _outlet_id
    _new_log[:table_id]         = _table_id
    _new_log[:table_state_id]   = _state_id
    _new_log[:table_state_name] = (TableState.find(_state_id)).name
    _new_log[:user_id]          = _user_id
    _log_obj = _new_log.save #Save new table log
    Table.where(:id => _table_id).update_all(:table_state_id => _state_id)
    return _log_obj
  end
end