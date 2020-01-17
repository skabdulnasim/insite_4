$(document).ready ->

  $(document).on "click", ".add_fields", (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))

  $(document).on 'click', '.remove_thirdparty_configuration', (event) ->
    if !window.confirm('Are you sure to delete this thirdparty configuration?')
      return false
    thirdparty_configuration_id = $(this).data("thirdparty-configuration-id")
    if thirdparty_configuration_id != undefined
      request = $.ajax(
        type: 'POST'
        url: "/sections/delete_thirdparty_configuration"
        dataType: "json"
        data:
          thirdparty_configuration_id: thirdparty_configuration_id
      )
    $(this).parents('.parent_div').next('input[type=hidden]').remove()
    $(this).parents('.parent_div').remove()
    event.preventDefault()