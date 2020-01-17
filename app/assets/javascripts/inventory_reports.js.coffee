# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
  $(document).ready ->
    sortTable $('#mytable'), 'asc'
  $(document).on "keyup change", ".purchase-date-input",->
    from_date = $(".purchase-from-date").val()
    store_id = $(".export-purchase-report").attr("data-store-id")
    href = "/inventory_reports/stock_purchase.csv?&from_date=#{from_date}&store_id=#{store_id}"
    $(".export-purchase-report").prop('href', href);
    return
  $(document).on "change", ".in-hand", ->   
    val = $('[name="units_ids[]"]:checked').length
    if val > 5
      Materialize.toast("You can Select Maximum Five (5) Branch.", 5000,'red')
      $(this).prop('checked', false)
    return  

  $(document).on "change", ".in-store", ->  
    val = $('[name="units_idss[]"]:checked').length
    if val > 10
      Materialize.toast("You can Select Maximum Ten (10) Branch.", 5000,'red')
      $(this).prop('checked', false)
    return  
  $(document).on "change", ".filled-in", ->
    filter = ""
    if $('.thresh-hold-filter').val() != ""
      filter = filter + "&filter=" + $('.thresh-hold-filter').val()
      return
    product_id = ""
    if $('.thresh-hold-product-id-filter').val() != ""
      product_id = product_id + "&product_id_filter=" + $('.thresh-hold-product-id-filter').val()
      return
    stores = ""
    $('.filled-in-store:checkbox:checked').map ->
      stores = stores + "&thresh_hold_store[]=" + $(this).val()
      return
    units = ""
    $('.thresh_hold_unid_ids').map ->
      units = units + "&thresh_hold_unid_ids[]=" + $(this).val()
      return
    cate = ""
    $('.filled-in:checkbox:checked').map ->
      cate = cate + "&product_category[]=" + $(this).val()
      return
    href = "/inventory_reports/stock_thresh_hold.csv?unit_id=0#{units}#{stores}#{cate}#{filter}#{product_id}"
    $(".export-thresh-hold-report").prop('href', href);

  $(document).on "change", ".filled-in-store", ->
    filter = ""
    if $('.thresh-hold-filter').val() != ""
      filter = filter + "&filter=" + $('.thresh-hold-filter').val()
      return
    product_id = ""
    if $('.thresh-hold-product-id-filter').val() != ""
      product_id = product_id + "&product_id_filter=" + $('.thresh-hold-product-id-filter').val()
      return
    stores = ""
    $('.filled-in-store:checkbox:checked').map ->
      stores = stores + "&thresh_hold_store[]=" + $(this).val()
      return
    units = ""
    $('.thresh_hold_unid_ids').map ->
      units = units + "&thresh_hold_unid_ids[]=" + $(this).val()
      return
    cate = ""
    $('.filled-in:checkbox:checked').map ->
      cate = cate + "&product_category[]=" + $(this).val()
      return
    href = "/inventory_reports/stock_thresh_hold.csv?unit_id=0#{units}#{stores}#{cate}#{filter}#{product_id}"
    $(".export-thresh-hold-report").prop('href', href);
  $(document).on "change", ".thresh-hold-filter", ->
    filter = ""
    if $('.thresh-hold-filter').val() != ""
      filter = filter + "&filter=" + $('.thresh-hold-filter').val()
      return
    product_id = ""
    if $('.thresh-hold-product-id-filter').val() != ""
      product_id = product_id + "&product_id_filter=" + $('.thresh-hold-product-id-filter').val()
      return
    stores = ""
    $('.filled-in-store:checkbox:checked').map ->
      stores = stores + "&thresh_hold_store[]=" + $(this).val()
      return
    units = ""
    $('.thresh_hold_unid_ids').map ->
      units = units + "&thresh_hold_unid_ids[]=" + $(this).val()
      return
    cate = ""
    $('.filled-in:checkbox:checked').map ->
      cate = cate + "&product_category[]=" + $(this).val()
      return
    href = "/inventory_reports/stock_thresh_hold.csv?unit_id=0#{units}#{stores}#{cate}#{filter}#{product_id}"
    $(".export-thresh-hold-report").prop('href', href);
  $(document).on "change", ".thresh-hold-product-id-filter", ->
    filter = ""
    if $('.thresh-hold-filter').val() != ""
      filter = filter + "&filter=" + $('.thresh-hold-filter').val()
      return
    product_id = ""
    if $('.thresh-hold-product-id-filter').val() != ""
      product_id = product_id + "&product_id_filter=" + $('.thresh-hold-product-id-filter').val()
      return
    stores = ""
    $('.filled-in-store:checkbox:checked').map ->
      stores = stores + "&thresh_hold_store[]=" + $(this).val()
      return
    units = ""
    $('.thresh_hold_unid_ids').map ->
      units = units + "&thresh_hold_unid_ids[]=" + $(this).val()
      return
    cate = ""
    $('.filled-in:checkbox:checked').map ->
      cate = cate + "&product_category[]=" + $(this).val()
      return
    href = "/inventory_reports/stock_thresh_hold.csv?unit_id=0#{units}#{stores}#{cate}#{filter}#{product_id}"
    $(".export-thresh-hold-report").prop('href', href);
  $(document).on "change", ".store-product-category,.stock-from-date,.stock-to-date,.stock_filter", ->
    category = $(".store-product-category").val()
    stock_filter = $(".stock_filter").val()
    from_date = $(".stock-from-date").val()   
    to_date = $(".stock-to-date").val() 
    store_id = $(".store_id").val()
    href = "/inventory_reports/store_stocks.csv?&from_date=#{from_date}&to_date=#{to_date}&store_id=#{store_id}&category=#{category}&stock_filter=#{stock_filter}"
    href_pdf = "/inventory_reports/store_stocks.pdf?&from_date=#{from_date}&to_date=#{to_date}&store_id=#{store_id}&category=#{category}&stock_filter=#{stock_filter}"
    $(".export-stock-report").prop('href', href);
    $(".export-stock-report-pdf").prop('href', href_pdf);
    return
  $(document).on "change", ".avaliable-category", ->
    categoryid = $(".avaliable-category").val()
    store_id = $(".avaliable-store").val()
    to_date = $("#to_date").val()
    href = "/inventory_reports/avaliable_stock_for_period.csv?&store_id=#{store_id}&category_id=#{categoryid}&to_date=#{to_date}"
    $(".export-avaliable-stock-report").prop('href', href);
    return 

  $(document).on "change", ".avaliable-category-for-stock", ->
    categoryid = $(".avaliable-category-for-stock").val()
    store_id = $(".avaliable-store").val()
    href = "/inventory_reports/avaliable_stock.csv?&store_id=#{store_id}&category_id=#{categoryid}"
    $(".export-avaliable-stock-report").prop('href', href);
    return 

  $(document).on "change", ".inhand-category, .inhand-branch", ->
    from_date = $(".inhand-from-date").val()   
    to_date = $(".inhand-to-date").val() 
    category_id = $(".inhand-category").val()
    unit_id = $(".inhand-branch").val()
    href = "/inventory_reports/stock_in_hand.csv?&from_date=#{from_date}&to_date=#{to_date}&unit_ids=#{unit_id}&catrgory=#{category_id}"
    $(".export-in-hand-report").prop('href', href);
    return    
  $(document).on "keyup change", ".avaliable-vendor", ->
    vendor = $(".avaliable-vendor").val()
    from_date = $(".avaliable-storename-from-date").val()   
    to_date = $(".avaliable-storename-to-date").val() 
    store_id = $(".avaliable-store-id").val()
    href = "/inventory_reports/stock_purchase.csv?&from_date=#{from_date}&to_date=#{to_date}&store_id=#{store_id}&vendor_name_filter=#{vendor}"
    href_pdf = "/inventory_reports/stock_purchase.pdf?&from_date=#{from_date}&to_date=#{to_date}&store_id=#{store_id}&vendor_name_filter=#{vendor}"
    $(".export-purchase-report").prop('href', href);
    $(".export-purchase-report-pdf").prop('href', href_pdf);
    return   
  $(document).on "keyup change", ".indent-report-input",->
    from_date = $(".indent-from-date").val()
    to_date = $(".indent-to-date").val()
    store_id = $(".indent-store-id").val()
    href = "/inventory_reports/store_indent.csv?&from_date=#{from_date}&to_date=#{to_date}&store_id=#{store_id}"
    $(".export-indent-report").prop('href', href);
    return
  $(document).on "keyup change", ".issue-report-input",->
    from_date = $(".issue-from-date").val()
    to_date = $(".issue-to-date").val()
    store_id = $(".issue-store-id").val()
    href = "/inventory_reports/stock_issue.csv?&from_date=#{from_date}&to_date=#{to_date}&store_id=#{store_id}"
    $(".export-issue-report").prop('href', href);
    return
  $(document).on "keyup change", ".vendor-payment-issue-report-input",->
    from_date = $(".issue-from-date").val()
    to_date = $(".issue-to-date").val()
    href = "/inventory_reports/vendor_payment.csv?&from_date=#{from_date}&to_date=#{to_date}"
    $(".export-issue-report").prop('href', href);
    return
  $(document).on "change", ".inventory-units",->
    unit_id = $(this).val()
    request = $.ajax
      url: "/stores/?id="+unit_id
      method: 'GET'
      context: this,
      dataType: "json"
    request.done (data, textStatus, jqXHR) ->
      data.stores = data
      result = JST["templates/reports/store"](data)
      $(this).parent("div").next("div").find(".unit_store").empty()
      $(this).parent("div").next("div").find(".unit_store").append result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return

  $(document).on "change", ".units-store",->
    unit_id = $(this).val()
    request = $.ajax
      url: "/stores/?id="+unit_id
      method: 'GET'
      dataType: "json"
    request.done (data, textStatus, jqXHR) ->
      data.stores = data
      result = JST["templates/reports/stock_store"](data)
      $(".store-units").empty()
      $(".store-units").append result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return

  $(document).on "change", ".thresh-hold-units-store",->
    unit_ids = new Array
    $.each $('input[name=\'thresh_hold_unid_ids[]\']:checked'), ->
      unit_ids.push $(this).val()
      return
    request = $.ajax
      url: "/stores/?ids[]="+unit_ids
      method: 'GET'
      dataType: "json"
    request.done (data, textStatus, jqXHR) ->
      data.stores = data
      result2 = JST["templates/reports/stock_store2"](data)
      $(".thresh-hold-store-units").empty()
      $(".thresh-hold-store-units").append result2
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return

  sortTable = (table, order) ->
    asc = order == 'asc'
    tbody = table.find('tbody')
    tbody.find('tr').sort((a, b) ->
      if asc
        $('td:first', a).text().localeCompare $('td:first', b).text()
      else
        $('td:first', b).text().localeCompare $('td:first', a).text()
    ).appendTo tbody
    return

  $(document).on "change keyup", ".sp-from-date,.sp-to-date,.sp-product-name,.sp-vendor", ->
    product_name = $(".sp-product-name").val()
    from_date = $(".sp-from-date").val()   
    to_date = $(".sp-to-date").val() 
    vendor_id = $(".sp-vendor").val()
    units = $("#units").val()
    href_csv = "/inventory_reports/unit_wise_stock_purchase.csv?&from_date=#{from_date}&to_date=#{to_date}&product_filter=#{product_name}&vendor_id=#{vendor_id}&units=#{units}"
    href_pdf = "/inventory_reports/unit_wise_stock_purchase.pdf?&from_date=#{from_date}&to_date=#{to_date}&product_filter=#{product_name}&vendor_id=#{vendor_id}&units=#{units}"
    $(".sp-report-csv").prop('href', href_csv);
    $(".sp-report-pdf").prop('href', href_pdf);
    return
 
  $(document).on "change", ".inventory-units-for-vendors",->
    unit_id = $(this).val()
    request = $.ajax
      url: "/vendors/?unit_id="+unit_id
      method: 'GET'
      context: this,
      dataType: "json"
    request.done (data, textStatus, jqXHR) ->
      data.vendors = data
      console.log data
      result = JST["templates/reports/vendor"](data)
      $(this).parent("div").next("div").find(".unit_vendor").empty()
      $(this).parent("div").next("div").find(".unit_vendor").append result
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return