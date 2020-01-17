$(document).ready(function(){
	// $(".binSelect").multiselect({
	// 	includeSelectAllOption: true
	// });
  $(".binSelect").each(function(){
    if (parseInt($(this).data("product-quantity")) == 0) {
      $(this).multiselect('disable');
    }
  });
	$("#submitBins").unbind().click(function(){
		var current_user_email = $("#current_user_email").data("current-user-email");
		var selected = $('.binSelect').find("option:selected");
    	var arrSelected = [];
    	selected.each(function(){
       	arrSelected.push($(this).val());
    	});
    $(".binSelect").each(function(){
      require_product_q = $(this)
    	require_product_quantity = $(this).data("product-quantity")
      console.log("require product:"+require_product_quantity)
      var selected_pick = $(this)
      stock_transfer_meta_id = $(this).data("transfer-meta-id")
    	$(this).find("option:selected").each(function(){
    		if (require_product_quantity > 0){
    			if (require_product_quantity >= $(this).data("bin-product-quantity")){
    				require_product_quantity = require_product_quantity - $(this).data("bin-product-quantity");
    				pickable_quantity = $(this).data("bin-product-quantity");
    			}else{
    				pickable_quantity = require_product_quantity;
    				require_product_quantity = 0;
          }
          require_product_q.data("product-quantity",require_product_quantity)
    			console.log("pickable from bin = "+pickable_quantity+" require_product_quantity"+ require_product_quantity);
    			var request = $.ajax({
            async:false,
    				url : "/api/v2/warehouses/pick_product?email="+current_user_email+"&device_id=YOTTO05",
    				type : "POST",
    				data : {bin_unique_id :$(this).val(),product_quantity:pickable_quantity}
    			});
    			request.done(function(data){
    				var update_picked_quantity = $.ajax({
                async:false,
                url: "/stock_transfers/update_picked_quantity",
                type: "GET",
                data: {id:stock_transfer_meta_id,picked_quantity:pickable_quantity}
            });
            update_picked_quantity.done(function(data){
              Materialize.toast("product picked from bin", 3000,'green')
              $("#product_picked_quantity").text(data.data.picked_quantity)
              if(data.data.quantity_transfered == data.data.picked_quantity){
                selected_pick.multiselect('disable');              }
            });
            update_picked_quantity.fail(function(jqXHR, textStatus){
              alert(textStatus);
            });
    			});
    			request.fail(function(jqXHR, textStatus){
            alert(textStatus);
    			});
    		}
    	$(this).remove();
      });
    });
	});
});