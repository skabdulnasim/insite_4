$(document).ready(function(){

  $(".percentage").keyup(function(e){
    if(e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)){
      Materialize.toast("Please enter numeric value.", 5000, 'red');
      return false;
    }
    else{
		  	var beneficiary_percentage_value = $(this).val();
		  	var field_val = $(this)
		  	var sum = 0
		  	$(".percentage").each(function(){
		  		sum+=parseInt($(this).val());
		  	});
    	if(sum>100){
    		Materialize.toast("Percentage limit exceeded", 5000, 'red');
    		field_val.val(field_val.val().substring(0,field_val.val().length-1))    		
    	}
    }
  });
});