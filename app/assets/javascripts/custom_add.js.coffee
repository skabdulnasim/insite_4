# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $(".remove_ad").on "click", ->  
    advertisement_gallery_id = this.id
    console.log advertisement_gallery_id
    advertisement_id = $(this).data("ad-id")
    console.log(advertisement_id)
    request = $.ajax(method:"POST",url: "/advertisements/remove_pic/",data:{gallery_id:advertisement_gallery_id,id:advertisement_id}, dataType: "json")
    request.done (data, textStatus, jqXHR) ->
      $("."+advertisement_gallery_id).slideUp("fast")
      alert "removing done"
      return
    request.error (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error:" + textStatus
      return
    return
  return

