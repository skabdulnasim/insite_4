$(document).ready ->
  $('.user-form').hide()

  ########### Function to validate license key ###########
  $(document).on "click", ".validate_license_key",->
    key = $('.license-key').val()
    request = $.ajax(
      type: 'POST'
      url: "/api/v2/users/verify_license.json"
      dataType: "json"
      data:
        license_key: $('.license-key').val()
        device_id: 'YOTTO05'
    )
    request.done (data, textStatus, jqXHR) ->
      console.log data
      if data.status is "ok"
        $('.license-form').hide()
        $('.user-form').show()
        $('#subdomain_license_key').val(data.data.license_key)
        $('#profile_appurl').val(data.data.url)
      else if data.status is "error"
        Materialize.toast(data.messages.internal_message, 3000, 'rounded')
        $('.user-form').hide()
        $('.license-form').show()
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      alert "error"
      return 
    return  
  return