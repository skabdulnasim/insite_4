var stocks =[];
var new_stock =[];
var salesLineChart;


load_dashboard_graph();

$(document).on("click", ".filter-dashboard-data", function() {
  var from_date = $("#from_date").val();
  var to_date = $("#to_date").val();

  if($("#product_search").val()!=""){
    var product_name = $('#product_search').val();
    load_dashboard_graph(from_date,to_date,product_name,true);
  }
  else
  {
    load_dashboard_graph(from_date,to_date);
  }

});


// $(document).on("keypress", "#product_search", function(event) {  
//   product_name = $('#product_search').val() 
//   request_product = $.ajax({
//     url: '/products/search_products',
//     type: 'GET',
//     data: {term:product_name },
//   });
//   request_product.done(function( data, textStatus, jqXHR ) {
//   });
 
// });

function po_receive(po_amount, po_receive, po_product_receive) {
  $(".card_header").html("Purchase order received today");
  $(".po_details").html("Purchase order received = "+po_receive+ ", Po product received = "+po_product_receive+ ", Po amount = " + po_amount);
}
function po_pending(po_pending, po_product_pending) {
  $(".card_header").html("Purchase order pending today");
  $(".po_details").html("Purchase order pending = "+po_pending+ ", Product pending = "+po_product_pending);
}
function po_issue(po_create, po_product_create) {
  $(".card_header").html("Purchase order create today");
  $(".po_details").html("Purchase order create = "+po_create+ ", Po product create = "+po_product_create);
}
function po_received_partially(po_receive_partially, po_product_receive_partially) {
  $(".card_header").html("Purchase order received partially today");
  $(".po_details").html("Po receive partially = " + po_receive_partially + ", Po product receive partially = " + po_product_receive_partially);
}
function audit_approved(audit_aprvd, product_approvd, delta_stock, positive_val, negative_val) {
  $(".card_header").html("Audit approved today");
  $(".po_details").html("Audit apprfoved = " + audit_aprvd + ", Number of product audit approved = " + product_approvd + ", Delta value = " + delta_stock + "; where positive value = " + positive_val + " and negative value is = " + negative_val);
}
function audit_pending(aud_pen, product_pending, pending_delta_stock, positive_val, negative_val) {
  $(".card_header").html("Audit pending today");
  $(".po_details").html("Audit pending = " + aud_pen + ", Number of product audit pending = " + product_pending + ", Delta value = " + pending_delta_stock + "; where positive value = " + positive_val + " and negative value = " + negative_val);    
}

$('.count').each(function () {
  $(this).prop('Counter',0).animate({
    Counter: $(this).text()
  }, {
    duration: 3000,
    easing: 'swing',
    step: function (now) {
      $(this).text(Math.ceil(now));
    }
  });
});

$(document).on("click",".close-card",function(e) {
  $('.default-sidebar').velocity(
    {translateY: 0}, {
      duration: 225,
      queue: false,
      easing: 'easeInOutQuad',
      complete: function() { $(this).css({ display: 'none'}) }
    }
  );
});


function load_dashboard_graph(from_date,to_date,product_name,call){
  if(salesLineChart) {
    salesLineChart.destroy();
  }
  
  var purchases =[];
  var dates=[];
  var ajaxData;

  var request = $.ajax({
    method: 'GET',
    url: '/inventory_dashboards.json',
    dataType: 'json',
    data: { from_date:from_date, to_date:to_date, product_name:product_name },
    success: function(data) {
      for(i=0; i<data.all_data.purchase.length; i++){
        purchases.push(Math.round(data.all_data.purchase[i].total_purchase));
        dates.push(data.all_data.purchase[i].created_time);
      }
      if(call==true){
        if(data.all_data.opening_stock != null){
          Materialize.toast("Data available", 4000, "green")
          $("#closing_stock").html(data.all_data.closing_stock.stock)
          $("#opening_stock").html(data.all_data.opening_stock.stock)
          $("#price").html("Price")
          $("#purchase").html(Math.round(data.all_data.purchase[0].total_purchase))
          $("#audit_approved").html(0)
          $("#delta_stock").html(0)
          $("#audit_pending").html(0)
          $("#hide_audit_approved").hide()
          $("#hide_audit_pending").hide()
          $("#purchase_received").hide()
          $("#purchase_pending").hide()
        }
        else
        {
          Materialize.toast("Data not available", 4000, "red")
        }
        
      }

      var lineChartData = {
      labels : dates,
      datasets : [
        {
          fillColor : "#ffcdd2",
          strokeColor : "#ef9a9a",
          pointColor : "#e57373",
          pointStrokeColor : "#FFF",
          pointHighlightFill : "#FFF",
          pointHighlightStroke : "#ef5350",
          data: purchases
        }
      ]
    }
    var ctx = $("#sales-area-canvas").get(0).getContext("2d");
    salesLineChart = new Chart(ctx).Line(lineChartData, {
      scaleShowGridLines : true,///Boolean - Whether grid lines are shown across the chart
      scaleGridLineColor : "rgba(255,255,255,0.4)",//String - Colour of the grid lines
      scaleGridLineWidth : 1,//Number - Width of the grid lines
      scaleShowHorizontalLines: true,//Boolean - Whether to show horizontal lines (except X axis)
      scaleShowVerticalLines: false,//Boolean - Whether to show vertical lines (except Y axis)
      bezierCurve : true,//Boolean - Whether the line is curved between points
      bezierCurveTension : 0.4,//Number - Tension of the bezier curve between points
      pointDot : true,//Boolean - Whether to show a dot for each point
      pointDotRadius : 5,//Number - Radius of each point dot in pixels
      pointDotStrokeWidth : 2,//Number - Pixel width of point dot stroke
      pointHitDetectionRadius : 20,//Number - amount extra to add to the radius to cater for hit detection outside the drawn point
      datasetStroke : true,//Boolean - Whether to show a stroke for datasets
      datasetStrokeWidth : 3,//Number - Pixel width of dataset stroke
      datasetFill : true,//Boolean - Whether to fill the dataset with a colour
      animationSteps: 15,// Number - Number of animation steps
      animationEasing: "easeOutQuart",// String - Animation easing effect
      tooltipTitleFontFamily: "'Roboto','Helvetica Neue', 'Helvetica', 'Arial', sans-serif",// String - Tooltip title font declaration for the scale label
      scaleFontSize: 12,// Number - Scale label font size in pixels
      scaleFontStyle: "normal",// String - Scale label font weight style
      scaleFontColor: "#00acc1",// String - Scale label font colour
      tooltipEvents: ["mousemove", "touchstart", "touchmove"],// Array - Array of string names to attach tooltip events
      tooltipFillColor: "rgba(255,255,255,0.8)",// String - Tooltip background colour
      tooltipTitleFontFamily: "'Roboto','Helvetica Neue', 'Helvetica', 'Arial', sans-serif",// String - Tooltip title font declaration for the scale label
      tooltipFontSize: 12,// Number - Tooltip label font size in pixels
      tooltipFontColor: "#000",// String - Tooltip label font colour
      tooltipTitleFontFamily: "'Roboto','Helvetica Neue', 'Helvetica', 'Arial', sans-serif",// String - Tooltip title font declaration for the scale label
      tooltipTitleFontSize: 14,// Number - Tooltip title font size in pixels
      tooltipTitleFontStyle: "bold",// String - Tooltip title font weight style
      tooltipTitleFontColor: "#000",// String - Tooltip title font colour
      tooltipYPadding: 8,// Number - pixel width of padding around tooltip text
      tooltipXPadding: 16,// Number - pixel width of padding around tooltip text
      tooltipCaretSize: 10,// Number - Size of the caret on the tooltip
      tooltipCornerRadius: 6,// Number - Pixel radius of the tooltip border
      tooltipXOffset: 10,// Number - Pixel offset from point x to tooltip edge
      responsive: true
    });
    }
  });
}







