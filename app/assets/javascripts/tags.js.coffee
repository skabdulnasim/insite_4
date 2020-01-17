$(document).ready ->
	$('.update_tag_status').click ->
	  tag_id = $(this).data('tag-id')
	  active = $(this).attr('data-value-active')
	  inactive = $(this).attr('data-value-inactive')
	  tag_status_value = if @checked then active else inactive
	  request = $.ajax(type:"post",url:"tags/update_status",data: id:tag_id,status:tag_status_value)
	  request.done (data, textStatus, jqXHR) ->
      Materialize.toast("Tag status updated to: #{tag_status_value}", 5000)
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "Error"
      return
	  