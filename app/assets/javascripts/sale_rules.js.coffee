# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $("#sale-rule-input-buy-qty").hide()
  $("#sale-rule-output-get-qty").hide()

	# Initializing the sale rule form wizard
  $('#wizard_vertical').steps
    headerTag: 'h3'
    bodyTag: 'section'
    transitionEffect: 'fade'
    stepsOrientation: 'horizontal'
    showFinishButtonAlways: true
    onStepChanging: (event, currentIndex, newIndex) ->
      true  
    onFinished: (event, currentIndex) ->
      form = $('.sale_rule_form_wizard')
      form.submit()
      return

	#alert "ok"
	# $("#sale-rule-input-buy-qty").hide()
	# $("#sale-rule-output-get-qty").hide()
	#$("#rule_specific").hide()

	$(document).on "change","#sale-rule-input-type",(event)->
		if $(this).val() is 'by_product'
			$("#sale-rule-input-amount").hide()
			$("#sale-rule-input-buy-qty").show()
		else if $(this).val() is 'by_amount'
			$("#sale-rule-input-buy-qty").hide()
			$("#sale-rule-input-amount").show()
		else if $(this).val() is 'by_lot'
			$("#sale-rule-input-amount").hide()
			$("#sale-rule-input-buy-qty").show()
		return

	$(document).on "change","#sale-rule-output-type",(event)->
		if $(this).val() is 'by_product'
			$("#sale-rule-output-amount").hide()
			$("#sale-rule-output-get-qty").show()
		else if $(this).val() is 'by_amount'
			$("#sale-rule-output-get-qty").hide()
			$("#sale-rule-output-amount").show()
		else if $(this).val() is 'by_lot'
			$("#sale-rule-output-amount").hide()
			$("#sale-rule-output-get-qty").show()
		else if $(this).val() is 'by_percentage'
			$("#sale-rule-output-get-qty").hide()
			$("#sale-rule-output-amount").show()
		return

	$(document).on "change","#sale-rule-type",(event)->
		if $(this).val() is 'specific'
			#$("#sale-rule-input-type").find('option[value="by_product"]').attr("selected",true)
			$("#sale_rule_specific_type").val("by_product")
			#$("#rule_specific").show()
			$("#sale-rule-input-type").val("by_product")
			$("#sale-rule-input-amount").hide()
			$("#sale-rule-input-buy-qty").show()
		else if $(this).val() is 'generic'
			#$("#sale-rule-input-type").find('option[value="by_amount"]').attr("selected",true)
			$("#sale-rule-input-type").val("by_amount")
			$("#sale-rule-input-buy-qty").hide()
			$("#sale-rule-input-amount").show()
		return

	$(document).on "change","#menu_card",(event)->
		$("#selected_menu_card").val $(this).val()
		return