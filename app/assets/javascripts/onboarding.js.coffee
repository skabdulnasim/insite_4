# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $(document).ajaxStart ->
    $('form').css 'opacity', 0.5
    return  
  $(document).ajaxStart ->
    $('form').css 'opacity', 1
    return  

  # Sorting unittypes
  # $("#unit_address").geocomplete()
  $('#unittypes').sortable
    axis: 'y'
    handle: '.handle'
    update: (event, ui) ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
      return
  $('.single_input_submit_form').change ->
    $(this).parent('form').submit()
    return

  # Trigger to close new unittype form
  $(document).on "click", ".close-unittype-form", ->
    $('#new_unittype').hide();
    $('#new_branch_type_link').show();
    $('#branch_type_edit_modal').closeModal()
    return

  # Trigger to close new unittype form
  $(document).on "click", ".close-vendor-form", ->
    $('#new_vendor').hide();
    $('#new_vendor_link').show();
    $('#vendor_edit_modal').closeModal()    
    return 

  # Trigger to close new user form
  $(document).on "click", ".close-user-form", ->
    $('#new_user').hide();
    $('#new_user_link').show();
    return  

  # Trigger to close new taxclass form
  $(document).on "click", ".close-taxclass-form", ->
    $('#new_tax_class').hide();
    $('#new_tax_class_link').show();
    $('#tax_class_edit_modal').closeModal()    
    return    

  # Trigger to close new taxgroup form
  $(document).on "click", ".close-taxgroup-form", ->
    $('#new_tax_group').hide();
    $('#new_tax_group_link').show();
    $('#tax_group_edit_modal').closeModal()    
    return  

  # Trigger to close new catalog form
  $(document).on "click", ".close-catalog-form", ->
    $('#new_menu_card').hide();
    $('#new_catalog_link').show();
    $('#menu_card_edit_modal').closeModal()    
    return   

  # Trigger to close new user form
  $(document).on "click", ".close-product_unit-form", ->
    $('#new_product_unit').hide();
    $('#new_product_unit_link').show();
    $('#product_unit_edit_modal').closeModal()      
    return   

  # Trigger to close new user form
  $(document).on "click", ".close-product-basic-unit-form", ->
    $('#new_product_basic_unit').hide();
    $('#new_basic_unit_link').show();
    $('#product_basic_unit_edit_modal').closeModal()      
    return      

  $(document).on "click", "#new_role_link", ->
    $("#new_role_link").html("Loading please wait ...")

  $(document).on "click", ".close-role-form", ->
    $('#new_role').hide();
    $('#new_role_link').html("Add new user role ...");
    $('#new_role_link').show();
    return  

  $(document).on "click", "#onboarding_new_role_link", ->
    $("#onboarding_new_role_link").html("Loading please wait ...")

  $(document).on "click", ".close-role-form", ->
    $('#onboarding_new_role').hide();
    $('#onboarding_new_role_link').html("Add new user role ...");
    $('#onboarding_new_role_link').show();
    return  

  $('.business_type_select').change ->
    $('.business_type_form').submit()
    return 

  # Trigger to open modal
  $(document).on "click", ".edit_branch_type_link", ->
    $('#branch_type_edit_modal').openModal()
    return 
    
  # Trigger to open modal
  $(document).on "click", ".new_unit_link", ->
    $('#new_unit_modal').openModal()
    return  

  # Trigger to open modal
  $(document).on "click", ".edit_unit_link", ->
    $('#edit_unit_modal').openModal()
    return      

  # Trigger to open modal
  $(document).on "click", ".edit_role_link", ->
    $('#role_edit_modal').openModal()
    return 

  # Trigger to open modal
  $(document).on "click", ".edit_vendor_link", ->
    $('#vendor_edit_modal').openModal()
    return   
  
  # Trigger to open modal
  $(document).on "click", ".edit_tax_class_link", ->
    $('#tax_class_edit_modal').openModal()
    return 

  # Trigger to open modal
  $(document).on "click", ".edit_tax_group_link", ->
    $('#tax_group_edit_modal').openModal()
    return  

  # Trigger to open modal
  $(document).on "click", ".edit_product_unit_link", ->
    $('#product_unit_edit_modal').openModal()
    return   

  # Trigger to open modal
  $(document).on "click", ".edit_product_basic_unit_link", ->
    $('#product_basic_unit_edit_modal').openModal()
    return     

  # Trigger to open modal
  $(document).on "click", ".edit_menu_card_link", ->
    $('#menu_card_edit_modal').openModal()
    return 
      
  $(document).on "keyup", "#unit_address", ->
    $("#unit_address").geocomplete()
    return

  # Removing nested fields
  $(document).on "click", ".remove_fields", (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('section').hide()
    event.preventDefault()
    
  # Adding nested fields
  $(document).on "click", ".add_fields", (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()
  
  $(document).on "click", ".collapsible", ->
    $('.collapsible').collapsible()
    return

  $(document).on "click", ".collapsible-header", ->
    module = $(this).data('module')
    $(".permissions_of_#{module}").hide()

  $(document).on "click", ".permission-radio", ->
    permission = $(this).val()
    module = $(this).data('module')
    if permission is 'read'
      $(".permissions_of_#{module}").hide()
      $(".permission_of_#{module}").prop("checked", false)
      $(".permission_#{module}_read").prop("checked", true)
    else if permission == 'manage'
      $(".permissions_of_#{module}").hide()
      $(".permission_of_#{module}").prop("checked", false)
      $(".permission_#{module}_manage").prop("checked", true)
    else
      $(".permissions_of_#{module}").show()
      $(".permission_of_#{module}").prop("checked", false)




