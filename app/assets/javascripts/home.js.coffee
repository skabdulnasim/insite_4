# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
#******************************************* OLD Code ******************************************* #
############################################ ajax loader image #################################################
  $(document).ajaxStart ->
    $("#background-blocker").css "display", "block"
    $(".maap").css "opacity", "0.7"
    return
  
  $(document).ajaxComplete ->
    $("#background-blocker").css "display", "none"
    $(".maap").css "opacity", "0.7"
    return
  
################################################################################################################
  
  ############################## to short the table in dashboard report#################################
  # $ ->
  #   $("#sort-element-table").stupidtable()
  #   $("#sort-inv-table").stupidtable()
  #   return
  #########################################################################################
  $(".map").on "change", ->
    location = $("#location").val()
    menu_product = $("#menu_product").val()
    source = $("#source").val()
    #alert location
    #alert menu_product
    #alert source
    request_addr = undefined
    request_addr = $.ajax(url: "/units/fetch_units.json/?location="+location+"&menu_product="+menu_product+"&source="+source)
    request_addr.done (data, textStatus, jqXHR) ->
      console.log data
      # handler = Gmaps.build("Google")
      # handler.buildMap
#        
        # # pass in other Google Maps API options here
        # internal:
          # id: "map"
      # , ->
        # markers = handler.addMarkers(data)
        # handler.bounds.extendWith markers
        # handler.fitMapToBounds()
        # return
        
      class RichMarkerBuilder extends Gmaps.Google.Builders.Marker #inherit from builtin builder
        #override create_marker method
        create_marker: ->
          options = _.extend @marker_options(), @rich_marker_options()
          @serviceObject = new RichMarker options #assign marker to @serviceObject
      
        rich_marker_options: ->
          marker = document.createElement("div")
          marker.setAttribute 'class', 'marker_container'
          marker.innerHTML = @args.marker
          { content: marker }
      
      handler = Gmaps.build 'Google', { builders: { Marker: RichMarkerBuilder} } #dependency injection
      
      #then standard use
      handler.buildMap { provider: {}, internal: {id: 'map'} }, ->
        # markers = handler.addMarkers([
          # {"lat": 0, "lng": 0, 'marker': '<span>Here!</span>'}
        # ])
        markers = handler.addMarkers(data)
        handler.bounds.extendWith(markers)
        handler.fitMapToBounds()
        return
      return
    request_addr.error (jqXHR, textStatus, errorThrown) ->
      #alert "AJAX Error:" + textStatus
      return 
    #alert json_array[0]
    return
  
  $("#categories").on "change", -> 
    category_id = $(this).val()    
    request = $.ajax(url: "/home/get_products/?category_id="+category_id, dataType: "json") 
    request.done (data, textStatus, jqXHR) ->
      data.product_name_info = data 
      result = undefined
      result = JST["templates/dashboard/product_list"](data)
      $("#product-selector").html result
      return
    return
  
  $(".product_chart_tab").on "click", ->
    $("#sell_chart").html ""
    $.fn.menu_products()
    return
  
  $(".inventory_menu_div").on "click", ->
    $("#chartdiv").html ""
    $.fn.inventory_product()
    return  
    
  $("#take-tour-btn").on "click", ->
   
    step1_data =
      heading: "Hello"
      message: "Welcome to"
      footer:"TOUCH VENTORY"

    step1_data.data = step1_data
    
    step2_data =
      heading: "NOTIFICATION SECTION"
      message: "This is the dashboard notification section where you can view the recent updates"
    
    step2_data.data = step2_data
       
    step3_data =
      heading: ""
      message: "Here,you can view the recent comments"
    
    step3_data.data = step3_data
    
    step4_data =
      heading: "LIVE CHAT"
      message: "Have a real-time chat with the support team"
    
    step4_data.data = step4_data
    
    step5_data =
      heading: "The TREE STRUCTURE"
      message: "The heirarchy of the company/organisation is explained in this section"
    
    step5_data.data = step5_data
    
    step6_data =
      heading: "THE MENU SECTION"
      message: "This is the navigation bar where you will have all the menus of the Touch Ventory portal"
    
    step6_data.data = step6_data
    
    options=
      showBullets: true
      
    intro = introJs()
    intro.setOptions showBullets: true
    intro.setOptions steps: [
      {
        element: document.querySelectorAll("#wrapper")[1]
        intro: JST["templates/tutorial/introduction"](step1_data)
        position: "left"
      }
      {
        element: document.querySelectorAll("#notice")[0]
        intro:"This is an instruction tour.Click 'Next' to proceed and 'Previous' to go back.Click anywhere outside the bubbletip to exit.You can also use your keyboard to navigate"
        position: "left"
      }
      {
        element: document.querySelectorAll("#notib")[0]
        intro: JST["templates/tutorial/dashboard_template"](step2_data)
        position: "left"
      }
      {
        element: document.querySelectorAll(".panel-primary")[0]
        intro: JST["templates/tutorial/dashboard_template"](step3_data)
        position: "left"
      }
      {
        element: document.querySelectorAll(".panel-green")[0]
        intro: "All the new tasks are listed here"
        position: "top"
      }
      {
        element: document.querySelectorAll(".panel-yellow")[0]
        intro: "You can view all the new orders here"
        position: "top"
      }
      {
        element: document.querySelectorAll(".panel-red")[0]
        intro: "The support tickets can be viewed here"
        position: "top"
      }
      {
        element: document.querySelectorAll(".panel-body")[0]
        intro: "BRANCH MAP- Here you can view the detailed map of the branches"
        position: "right"
      }
      {
        element: document.querySelectorAll(".list-group")[0]
        intro: "NOTIFICATION PANEL"
        position: "left"
      }
      {
        element: document.querySelectorAll(".btn-default")[0]
        intro: "View all the alerts or notification"
        position: "left"
      }
      {
        element: document.querySelectorAll(".chat-panel")[0]
        intro: JST["templates/tutorial/dashboard_template"](step4_data)
        position: "left"
      }
      {
        element: document.querySelectorAll("#treediv")[0]
        intro: JST["templates/tutorial/dashboard_template"](step5_data)
        position: "left"
      }
      {
        element: document.querySelectorAll("#side-menu")[0]
        intro: JST["templates/tutorial/dashboard_template"](step6_data)
        position: "right"
      }
      
    ]
    intro.start()
    return
  
  
  return
