 # Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  #----------------------------# POUCH DB #----------------------------#
  #--------------------------------------------------------------------#
  # Initializing PouchDB
  db = new PouchDB('inpos_cart_master_9')

  # Checking the adapter, wheather the browser is compatible or not
  console.log db.adapter

  # remoteCouch = false
  db.createIndex(index:
    fields: [
      'catalog_id'
      'product_id'
      'sku'
      'upc'
    ]
  ).then((result) ->
    console.log 'Creating index....'
    console.log result
    return
  ).catch (err) ->
    console.log 'Error occured while creating Index, description given below.'
    console.log err
    return
  
  # Add items to cart
  addToCart = (catalog_id, product_id, product_name, product_price, currency, sku, upc,focus_input) ->
    sku = '' if typeof sku is 'undefined'
    upc = '' if typeof upc is 'undefined'

    # Chech the item exists in database or not
    db.find(
      selector:
        catalog_id: $eq: catalog_id
        product_id: $eq: product_id
        sku: $eq: sku
        upc: $eq: upc
      ).then((result) ->
      if result.docs.length is 0
        # Insert item into database as it dont exist
        insertCartItem catalog_id, product_id, product_name, product_price, currency, sku, upc
        Materialize.toast
        Materialize.toast("Item added to cart", 2000)
      else
        # Update item quantity in database
        updateCartItemQuantity result.docs[0]._id
        Materialize.toast("Item quantity updated", 2000)
      return
    ).then(->
      showCart(catalog_id)
    ).then(->
      $("#{focus_input}").focus()
    ).catch (err) ->
      console.log 'Error occured while finding item in DB.'
      console.log err
      return
    return

  # Insert cart item in database
  insertCartItem = (catalog_id, product_id, product_name, product_price, currency, sku, upc) ->
    product_price = 0 if typeof product_price is 'undefined'
    item =
      _id: "#{catalog_id}_#{product_id}_#{(new Date).toISOString()}"
      catalog_id: catalog_id
      product_id: product_id
      sku: sku
      upc: upc
      product_name: product_name
      product_price: product_price
      currency: currency
      quantity: 1
    db.put item, (err, result) ->
      if !err
        console.log 'Successfully added an item to cart!'
      return

  # Update cart item quantity
  updateCartItemQuantity = (id) ->
    db.get(id).then((doc) ->
      # update quantity
      doc.quantity += 1
      doc._rev = doc._rev
      # put them back
      db.put doc
    ).then(->
      # fetch mittens again
      db.get id
    ).then (doc) ->
      console.log doc
      return

  # Show cart
  showCart = (catalog_id) ->
    catalog_id = parseInt(catalog_id)
    db.find(
      selector:
        catalog_id: $eq: catalog_id
      ).then((result) ->
        redrawCartUI result.docs
        return
    ).catch (err) ->
      console.log 'Error occured while finding item in DB.'
      console.log err
      return
    return

  # Generate cart UI
  redrawCartUI = (docs) ->
    $("#pos-cart").html('')
    grand_total = 0
    docs.forEach (doc) ->
      grand_total += doc.quantity*doc.product_price
      $("#pos-cart").append createCartItem(doc)
      return
    $("#cart_grand_total").html grand_total
    return

  # Draw individual cart item UI
  createCartItem = (item) ->
    html= "<li class='collection-item avatar custom-list-item' data-product-id='#{item.product_id}'>
              <i class='material-icons circle cursor-pointer theme-green transition-5 remove-from-cart remove-from-cart-#{item.product_id}' data-db-id='#{item._id}' title='Remove from cart'>check</i>
              <span class='title'>#{item.product_name}</span>
              <span class='secondary-content'>#{item.currency} #{item.quantity*item.product_price}</span>
              <p class='grey-text text-darken-2 font-07'>QTY: #{item.quantity}"
    html+= " | SKU: #{item.sku}" unless item.sku is ''
    html+= " | UPC: #{item.upc}" unless item.upc is ''
    html+= "</p></li>"

  # User pressed the delete button for an item, delete it
  deleteButtonPressed = (id) ->
    db.get(id).then((doc) ->
      db.remove doc
    ).then(->
      showCart($("#pos_catalog_id").val())
    )
    return

  # Clear all items from cart for a given catalog
  clearCartItems = (catalog_id) ->
    catalog_id = parseInt(catalog_id)
    db.find(
      selector:
        catalog_id: $eq: catalog_id
      ).then((result) ->
        result.docs.forEach (doc) ->
          db.remove doc
        return
    ).then(->
      showCart(catalog_id)
    ).catch (err) ->
      console.log 'Error occured while finding item in DB.'
      console.log err
      return
    return

  #----------------------------# API Calls #---------------------------#
  #--------------------------------------------------------------------#

  # Place new order
  place_new_order = (cart_items, email_id, unit_id, catalog_id, deliverable_type, deliverable_id, consumer_type, consumer_id, currency, pos_id, customer_id) ->
    # AJAX request to place new order
    request = $.ajax(
      type: 'POST'
      url: "/api/v2/orders"
      dataType: "json"
      data:
        email:            email_id
        device_id:        'YOTTO05'
        order:
          unit_id:          unit_id
          source:           'fos'
          device_id:        'YOTTO05'
          consumer_type:    consumer_type
          consumer_id:      consumer_id
          deliverable_type: deliverable_type
          deliverable_id:   deliverable_id
          order_details_attributes: cart_items
          customer_id: customer_id
    )
    request.done (data, textStatus, jqXHR) ->
      console.log data
      if data.status is "ok"
        Materialize.toast(data.messages.internal_message, 2000)
        # Generating bill
        timestamp = new Date().getTime()
        bill_request = $.ajax(
          type: 'POST'
          url: "/api/v2/bills"
          dataType: "json"
          data:
            email:            email_id
            device_id:        'YOTTO05'
            bill:
              biller_id:        consumer_id
              biller_type:      consumer_type
              pax:              '1'
              unit_id:          unit_id
              deliverable_id:   deliverable_id
              deliverable_type: deliverable_type
              device_id:        "POS#{pos_id}"
              bill_orders_attributes: [
                {
                  order_id: data.data.id
                }
              ]
        )
        # If bill request completed successfully
        bill_request.done (data, textStatus, jqXHR) ->
          if data.status is "ok"
            Materialize.toast(data.messages.internal_message, 2000)
            # Clear all items from cart for a given catalog
            clearCartItems(catalog_id)
            $("#customer-mobile-no").val("")
            $("#deliverable-container").html("")

            $('.right-sidebar').addClass('active')
            #Open Payment Modal
            $('#right-sheet-payment-modal').openModal
              ready: ->
                $('.bottom-sheet').removeClass 'bottom-sheet-complete'
                return
              complete: ->
                $('.bottom-sheet').addClass 'bottom-sheet-complete'
                return
            $('#right-sheet-payment-modal').removeClass('display-none')
            $('#right-sheet-payment-modal').addClass('display-block')

            $("#right-sheet-payment-modal-header").html("Make Payment");
            data.bill_response = data.data
            data.currency = currency
            cash_settlement_result = JST["templates/pos/cash_settlement"](data)
            $("#CashPayment").html cash_settlement_result
            make_settlement_result = JST["templates/pos/make_settlement_summary"](data)
            $("#MakeSettlementSummary").html make_settlement_result
            card_settlement_result = JST["templates/pos/card_settlement"](data)
            $("#CardPayment").html card_settlement_result
          else
            Materialize.toast(data.messages.internal_message, 2000)
            $('.right-sidebar').addClass('active')
        bill_request.error (jqXHR, textStatus, errorThrown) ->
          Materialize.toast("Sorry!! error occured while generating bill.", 2000,'round')
          $('.right-sidebar').addClass('active')
      else
        Materialize.toast(data.messages.internal_message, 5000,'round')
        $('.right-sidebar').addClass('active')
    request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast('Sorry!! error occured while placing order', 2000,'round')
      $('.right-sidebar').addClass('active')
      return
    return


  make_bill_settlement = (email_id, bill_id, client_id, client_type, pos_id, payment_data, currency) ->
    settlement_request = $.ajax(
      type: 'POST'
      url: "/api/v2/settlements"
      dataType: "json"
      data:
        email:            email_id
        device_id:        'YOTTO05'
        settlement:
          bill_id       : bill_id
          tips          : 0
          client_id     : client_id
          client_type   : client_type
          device_id     : pos_id
          payments_attributes: payment_data
    )
    settlement_request.done (data, textStatus, jqXHR) ->
      if data.status is "ok"
        Materialize.toast(data.messages.internal_message, 2000)
        generate_invoice(bill_id, currency)
      else
        Materialize.toast(data.messages.internal_message, 2000)
    settlement_request.error (jqXHR, textStatus, errorThrown) ->
      Materialize.toast("#{textStatus}", 5000)
      return
    return

  # Generate Invoice
  generate_invoice = (bill_id, currency) ->
    request = $.ajax(
      type: 'GET'
      url: "/api/v2/bills/#{bill_id}"
      dataType: "json"
      data:
        resources: 'order_items,tax_details,discount_details,payment_details,delivery_details,unit_details'
    )
    request.done (data, textStatus, jqXHR) ->
      console.log data
      $('.modal-content').addClass('active')
      #Close Payment Modal
      $('#right-sheet-payment-modal').closeModal
        ready: ->
          $('.bottom-sheet').removeClass 'bottom-sheet-complete'
          return
        complete: ->
          $('.bottom-sheet').addClass 'bottom-sheet-complete'
          return
      $('#right-sheet-payment-modal').removeClass('display-block')
      $('#right-sheet-payment-modal').addClass('display-none')

      # Open Invoice Modal
      $('#right-sheet-invoice-modal').openModal
        ready: ->
          $('.bottom-sheet').removeClass 'bottom-sheet-complete'
          return
        complete: ->
          $('.bottom-sheet').addClass 'bottom-sheet-complete'
          return
      $('#right-sheet-invoice-modal').removeClass('display-none')
      $('#right-sheet-invoice-modal').addClass('display-block')

      $("#invoice-modal-data-container").html ''
      $("#right-sheet-invoice-modal-header").html("Invoice");
      page_type = $("#invoice_page_type").val()
      if page_type is 'a4'
        data.page_size= 640
      else if page_type is 'a5'
        data.page_size= 440
      else
        data.page_size= 540
      data.response = data.data
      data.currency = currency
      data.action = "simple_bill_invoice"
      invoice_result = JST["templates/pos/invoice"](data)
      $("#invoice-modal-data-container").html invoice_result
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
    return

  # Bill edit action
  $(document).on "click", ".check_promo_code", ->
    bill_id = $(this).data("bill-id")
    bill_amount = parseFloat($(this).data("bill-amount"))
    currency = $(this).data("currency")
    code = $("#promo_code_#{bill_id}").val()
    if code is ""
      Materialize.toast("Please provide promo code.", 5000)
    else
      promo_request = $.ajax(
        type: 'GET'
        url: "/alpha_promotions.json"
        dataType: "json"
        data:
          promo_code: code
      )
      promo_request.done (data, textStatus, jqXHR) ->
        promo_code = data[0]
        if promo_code
          amount = promo_code.promo_value if promo_code.promo_type is "by_amount"
          amount = (bill_amount * promo_code.promo_value / 100) if promo_code.promo_type is "by_percentage"
          amount = bill_amount if amount > bill_amount
          $("#promo_value_#{bill_id}").val(amount.toFixed(2))
          Materialize.toast("#{currency} #{amount} discount can be applied using promo code #{code}.", 3000)
        else
          $("#promo_value_#{bill_id}").val("")
          Materialize.toast("Promo code #{code} not found.", 3000)
        return
      promo_request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("#{textStatus}", 3000)
        return
      return
    return

  $(document).on "click", ".apply_promo_code", ->
    bill_id = $(this).data("bill-id")
    currency = $(this).data("currency")
    action = $(this).data("action")
    code = $("#promo_code_#{bill_id}").val()

    if code is ""
      Materialize.toast("Please provide promo code.", 3000)
    else
      promo_code_request = $.ajax(
        type: 'PUT'
        url: "/bills/#{bill_id}.json"
        dataType: "json"
        data:
          bill_id:      bill_id
          promo_code:   code
      )
      promo_code_request.done (data, textStatus, jqXHR) ->
        Materialize.toast("Bill ID #{bill_id} updated.", 3000)
        console.log data
        # get_bill_details(bill_id,currency,action)
        data.bill_response = data
        data.currency = currency
        cash_settlement_result = JST["templates/pos/cash_settlement"](data)
        $("#CashPayment").html cash_settlement_result
        make_settlement_result = JST["templates/pos/make_settlement_summary"](data)
        $("#MakeSettlementSummary").html make_settlement_result
        card_settlement_result = JST["templates/pos/card_settlement"](data)
        $("#CardPayment").html card_settlement_result
      promo_code_request.error (jqXHR, textStatus, errorThrown) ->
        Materialize.toast("#{jqXHR.responseText}", 3000)
        return
      return
    return

  #----------------------# Page Event Handling #-----------------------#
  #--------------------------------------------------------------------#

  showCart($("#pos_catalog_id").val())

  # Add to cart button on click event handling
  # $(document).on "click", ".add-to-cart", (event) ->
  #   addToCart $(this).data('catalog-id'), $(this).data('catalog-product-id'), $(this).data('product-name'), $(this).data('product-price'), $(this).data('currency'), $(this).data('sku'), '', ''
  #   return
  
  $(document).on "click", ".add-to-cart", (event) ->
    catalog_id = $(this).data('catalog-id')
    menu_product_id = $(this).data('catalog-product-id')
    product_name = $(this).data('product-name')
    product_price = $(this).data('product-price')
    currency = $(this).data('currency')
    product_sku = $(this).data('sku')
    stock_check_on_order = $("#stock_check_on_order").val()
    pos_id = $(this).data('pos-id')

    request = $.ajax(
      type: 'GET'
      url: "/pos_terminals/#{pos_id}/find_product"
      dataType: "json"
      data:
        product_name: product_name
        catalog_id: catalog_id
    )
    request.done (data, textStatus, jqXHR) ->
      $("#product_id").val ''
      $("#product_search").val ''
      data.response = data.data
      data.catalog_id = catalog_id
      data.currency = currency
      console.log data
      if stock_check_on_order == 'enabled'
        if typeof data.response != 'undefined' and data.response.length > 0
          if $('#upc_based_operations').val() is 'yes'
            #Open UPC Modal
            $('#upc-modal').openModal()
            upc_result = JST["templates/pos/upc_input"](data)
            $("#upc-modal-content").html upc_result
          else  
            addToCart(catalog_id, menu_product_id, product_name, product_price, currency, product_sku,'','')
        else
          Materialize.toast("Stock not available for #{product_name}", 2000, 'round')
      else
        response_data = []
        response_data.push data.response
        console.log response_data[0].product_found
        console.log response_data[0].menu_product_found
        data.response = response_data
        if response_data[0].product_found == 'yes'
          if response_data[0].menu_product_found == 'yes'
            if $('#upc_based_operations').val() is 'yes'
              #Open UPC Modal
              $('#upc-modal').openModal()
              upc_result = JST["templates/pos/upc_input"](data)
              $("#upc-modal-content").html upc_result
            else  
              addToCart(catalog_id, menu_product_id, product_name, product_price, currency, product_sku,'','')
          else
            Materialize.toast("#{product_name} is not added to catalog ", 2000, 'round')
        else
          Materialize.toast("Product not found with #{product_name}", 2000, 'round')
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      return
    return  

  # Add to cart button on click event handling
  $(document).on "click", ".remove-from-cart", (event) ->
    deleteButtonPressed $(this).data('db-id')
    return

  # Adding dynamic association fields
  $(document).on "click", ".add_fields", (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  $(document).on "click", ".clear-cart-items", (event) ->
    clearCartItems($("#pos_catalog_id").val())
    return

  $(document).on "mouseenter", ".custom-list-item", (event) ->
    product_id = $(this).data('product-id')
    console.log "product ID #{product_id}"
    $(".remove-from-cart-#{product_id}").removeClass('theme-green')
    $(".remove-from-cart-#{product_id}").addClass('red')
    $(".remove-from-cart-#{product_id}").html('delete_sweep')
    return

  $(document).on "mouseleave", ".custom-list-item", (event) ->
    product_id = $(this).data('product-id')
    console.log "product ID #{product_id}"
    $(".remove-from-cart-#{product_id}").removeClass('red')
    $(".remove-from-cart-#{product_id}").addClass('theme-green')
    $(".remove-from-cart-#{product_id}").html('check')
    return

  $(document).on "keyup change", '.settlement_amount_input', (event) ->
    amount = parseFloat($(this).val())
    mode = $(this).data('settlement-mode')
    if amount > 0
      $("##{mode}_settlement_checkbox").prop('checked', true);
    else
      $("##{mode}_settlement_checkbox").prop('checked', false);
    return

  # Place a new order
  $(document).on "click", "#place_new_order", (event) ->
    Materialize.toast('Processing your request...', 2000,'')
    $('.right-sidebar').removeClass('active')
    email_id = $(this).data("email-id")
    unit_id = $(this).data("unit-id")
    catalog_id = $(this).data("catalog-id")
    deliverable_type = $('#order_deliverable_type').val()
    deliverable_id = parseInt($('#order_deliverable_id').val())
    consumer_type = $(this).data("consumer-type")
    consumer_id = $(this).data("consumer-id")
    currency = $(this).data("currency")
    pos_id = $(this).data("pos-id")
    resource_deliverable_type = $('#resource_order_deliverable_type').val()
    resource_deliverable_id = parseInt($('#resource_order_deliverable_id').val())
    customer_id = parseInt($("#customer_id").val())
    if deliverable_id > 0 || resource_deliverable_id > 0
      # Fetch cart items from PouchDB
      if resource_deliverable_id > 0
        deliverable_type = resource_deliverable_type
        deliverable_id = resource_deliverable_id
        if customer_id > 0
          customer_id = customer_id
        else
          customer_id = ''
      else
        customer_id = ''
      cart_items = new Array
      db.find(
        selector:
          catalog_id: $eq: catalog_id
        ).then((result) ->
          result.docs.forEach (doc) ->
            item =
              menu_product_id: doc.product_id
              quantity: doc.quantity
              preferences: ''
              parcel: '1'
              product_unique_identity: doc.sku
              properties:
                upc: doc.upc
            cart_items.push item
          return
      ).then(->
        # Place order here if cart items present
        if cart_items.length is 0
          Materialize.toast("Please add some items in cart before continuning.", 3000,'round')
          $('.right-sidebar').addClass('active')
          return
        else
          # API Call
          place_new_order cart_items, email_id, unit_id, catalog_id, deliverable_type, deliverable_id, consumer_type, consumer_id, currency, pos_id, customer_id
      ).catch (err) ->
        console.log 'Error occured while finding item in DB.'
        console.log err
        return
    else
      Materialize.toast("Please provide delivery details before continuning.", 3000,'round')
      $('.right-sidebar').addClass('active')
    return

  # Make Settlement
  $(document).on "click", '#make_payment', (event) ->
    $('.modal-content').removeClass('active')
    email_id = $(this).data("email-id")
    pos_id = $(this).data("pos-id")
    currency = $(this).data("currency")
    client_id = $(this).data("client-id")
    client_type = 'User'
    bill_id = parseFloat($("#settlement_bill_id").val())
    bill_amount = parseFloat($("#settlement_bill_amount").val())
    payment_data = new Array
    settled_amount = 0
    $('.settlement_mode_checkbox:checkbox:checked').map ->
      payment_mode = $(this).data('settlement-mode')
      if payment_mode is "cash"
        cash_amount = parseFloat($("#cash_settlement_amount").val())
        arr =
          paymentmode_type : 'Cash'
          paymentmode_attributes :
            amount          : cash_amount
            balance_return  : 0
            tendered_amount : cash_amount
        payment_data.push arr
        settled_amount += cash_amount
      else if payment_mode is "card"
        card_amount = parseFloat($("#card_settlement_amount").val())
        card_no = $("#card_number").val()
        card_type = 'Debit'
        card_merchandiser = $("#card_merchandiser").val()
        arr =
          paymentmode_type : 'Card'
          paymentmode_attributes :
            amount       : card_amount
            no           : card_no
            valid_upto   : null
            card_type    : card_type
            bank         : null
            cvv          : null
            merchandiser : card_merchandiser
            name_on_card : null
        payment_data.push arr
        settled_amount += card_amount
    # Place order here if cart items present
    if settled_amount != bill_amount
      Materialize.toast("Oops! payable amount and settled amount is not matching.", 3000,'round')
      $('.modal-content').addClass('active')
      return
    else
      # API Call
      make_bill_settlement email_id, bill_id, client_id, client_type, pos_id, payment_data, currency
    return

  # Print function
  $(document).on "click", ".print", (event) ->
    #open new window set the height and width =0,set windows position at bottom
    a = window.open()
    #write gridview data into newly open window
    a.document.write document.getElementById('DivIdToPrint').innerHTML
    a.document.close()
    a.focus()
    #call print
    a.print()
    a.close()
    false
    return

  $(document).on "keypress", ".barcode-search", (event) ->
    if event.keyCode == 13
      pos_id = $(this).data('pos-id')
      catalog_id = $(this).data('catalog-id')
      currency = $(this).data('currency')
      sku = $(this).val()
      focus_input = ".barcode-search"
      request = $.ajax(
        type: 'GET'
        url: "/pos_terminals/#{pos_id}/find_barcode"
        dataType: "json"
        data:
          sku: sku
          catalog_id: catalog_id
      )
      request.done (data, textStatus, jqXHR) ->
        data.response = data.data
        data.catalog_id = catalog_id
        data.currency = currency
        if typeof data.response != 'undefined' and data.response.length > 0
          if $('#upc_based_operations').val() is 'yes'
            #Open UPC Modal
            $('#upc-modal').openModal()
            upc_result = JST["templates/pos/upc_input"](data)
            $("#upc-modal-content").html upc_result
          else
            addToCart(catalog_id, data.response[0].menu_product_id, data.response[0].product_name, data.response[0].properties.sell_price, currency, data.response[0].sku, focus_input)
            $('.barcode-search').val('')
        else
          Materialize.toast("Stock not available for SKU: #{sku}", 2000, 'round')
        # data.response = data.data
        # data.currency = currency
        # search_result = JST["templates/pos/barcode_search"](data)
        # $("#barcode-search-results").html search_result
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        console.log textStatus
        return
    return

  $(document).on "keypress", "#product_search", (event) ->
    if event.keyCode == 13  
      pos_id = $(this).data('pos-id')
      catalog_id = $(this).data('catalog-id')
      currency = $(this).data('currency')
      product_id = $("#product_id").val()
      product_name = $(this).val()
      focus_input = "#product_search"
      stock_check_on_order = $("#stock_check_on_order").val()
      request = $.ajax(
        type: 'GET'
        url: "/pos_terminals/#{pos_id}/find_product"
        dataType: "json"
        data:
          product_name: product_name
          catalog_id: catalog_id
      )
      request.done (data, textStatus, jqXHR) ->
        $("#product_id").val ''
        $("#product_search").val ''
        data.response = data.data
        data.catalog_id = catalog_id
        data.currency = currency
        console.log data
        if stock_check_on_order == 'enabled'
          if typeof data.response != 'undefined' and data.response.length > 0
            if $('#upc_based_operations').val() is 'yes'
              #Open UPC Modal
              $('#upc-modal').openModal()
              upc_result = JST["templates/pos/upc_input"](data)
              $("#upc-modal-content").html upc_result
            else  
              addToCart(catalog_id, data.response[0].menu_product_id, data.response[0].product_name, data.response[0].properties.sell_price, currency, data.response[0].sku,'',focus_input)
          else
            Materialize.toast("Stock not available for #{product_name}", 2000, 'round')
        else
          response_data = []
          response_data.push data.response
          console.log response_data[0].product_found
          console.log response_data[0].menu_product_found
          data.response = response_data
          if response_data[0].product_found == 'yes'
            if response_data[0].menu_product_found == 'yes'
              if $('#upc_based_operations').val() is 'yes'
                #Open UPC Modal
                $('#upc-modal').openModal()
                upc_result = JST["templates/pos/upc_input"](data)
                $("#upc-modal-content").html upc_result
              else  
                addToCart(catalog_id, response_data[0].menu_product_id, response_data[0].product_name, response_data[0].properties.sell_price, currency, response_data[0].sku,'',focus_input)
            else
              Materialize.toast("#{product_name} is not added to catalog ", 2000, 'round')
          else
            Materialize.toast("Product not found with #{product_name}", 2000, 'round')

        # data.response = data.data
        # data.currency = currency
        # search_result = JST["templates/pos/barcode_search"](data)
        # $("#barcode-search-results").html search_result
        return
      request.error (jqXHR, textStatus, errorThrown) ->
        console.log textStatus
        return
      return  

  $(document).on "keyup", "#product_search", (event) ->
    val = $("#product_id").val ''
    return    

  $(document).on "keypress", "#item-upc-input", (event) ->
    if event.keyCode == 13
      product_upc = $(this).val()
      catalog_id = parseInt($('#upc-item-catalog-id').val())
      menu_product_id = parseInt($('#upc-item-menu-product-id').val())
      product_name = $('#upc-item-name').val()
      product_price = parseInt($('#upc-item-sell-price').val())
      product_currency = $('#upc-item-currency').val()
      product_sku = $('#upc-item-sku').val()
      focus_input = ".barcode-search"
      addToCart(catalog_id, menu_product_id, product_name, product_price, product_currency, product_sku, product_upc, focus_input)
      $('.barcode-search').val('')
      $('#upc-modal').closeModal()
      return
    return
  $(document).on "click", ".close-invoice-modal", (event) ->
    $('#right-sheet-invoice-modal').closeModal
      ready: ->
        $('.bottom-sheet').removeClass 'bottom-sheet-complete'
        return
      complete: ->
        $('.bottom-sheet').addClass 'bottom-sheet-complete'
        return
    $('#right-sheet-invoice-modal').removeClass('display-block')
    $('#right-sheet-invoice-modal').addClass('display-none')
    return

  $('#download').on 'click', (e) ->
    e.preventDefault()
    $.fileDownload $(this).prop('href'),
      successCallback: (url) ->
        alert 'Success'
        return
      failCallback: (url) ->
        alert 'Fail'
        return
    return

  $(document).on "click", ".tally-xls-exporter", (event) ->
    pos_id = $(this).data('pos-id')
    prefix = $(this).data('bill-serial-prefix')
    # Download file
    $.fileDownload "/pos_terminals/tally_exporter.xls?pos_id=POS#{pos_id}&bill_serial_prefix=#{prefix}",
      successCallback: (url) ->
        $('#xls-export-modal').closeModal
          dismissible: true
          complete: ->
            $('.lean-overlay').remove()
            return
        return
      failCallback: (url) ->
        alert 'Failed to download file'
        return    # Download file

  $(document).on "click", ".close-tally-xls-exporter", (event) ->
    $('#xls-export-modal').closeModal
      dismissible: true
      complete: ->
        $('.lean-overlay').remove()
        return
    return
  return
