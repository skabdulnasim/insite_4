$(document).ready ->
  $(document).on "click", ".quotation-quickview", ->
    quotation_id = $(this).data("quotation-id")
    #currency = $(this).data("currency")
    data = {loader_type: 'color-spinner'}
    loader = JST['templates/loader'](data)
    $("#quotation_quickinfo_#{quotation_id}").html loader
    request = $.ajax(
      type: 'GET'
      url: "/quotations/#{quotation_id}.json"
      dataType: "json"
    )
    request.done (data, textStatus, jqXHR) ->  
      $(".quotation_collapse_#{quotation_id}").removeClass 'quotation-quickview'
      data.response = data
      result = JST["templates/quotations/quick_details"](data)
      $("#quotation_quickinfo_#{quotation_id}").html result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      $("#quotation_quickinfo_#{quotation_id}").html textStatus
      return
    return