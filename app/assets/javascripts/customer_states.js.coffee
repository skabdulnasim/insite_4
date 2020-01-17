$(document).ready ->
	$('.update_state_status').click ->
	  state_id = $(this).data('state-id')
	  active = $(this).attr('data-value-active')
	  inactive = $(this).attr('data-value-inactive')
	  state_status_value = if @checked then active else inactive
	  request = $.ajax(type:"post",url:"customer_states/update_status",data: id:state_id,status:state_status_value)
	  request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Customer State status updated to: #{state_status_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return
	