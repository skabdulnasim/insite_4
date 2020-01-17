// ChartJS related functions
// *************************

// Initializing all chart variables
var salesLineChart;
var myDoughnut;
var orderCountBarChart;
var profitLineChart;
var polarRevenueChart;

$(document).on("click", ".filter-dashboard-data", function() {
  load_dashboard_UI_components();
});

// Initializing dashboard components
function load_dashboard_UI_components() {

  //Building units/locations array
  var units_arr = new Array;
  $(".units-checkbox:checked").each(function(index) {
    val = $(this).attr('id');
    units_arr.push(val);
  });
  var from_date = $("#from_date").val();
  var to_date = $("#to_date").val();

  // Loading Spinners
  loader = JST["templates/loader"](loader_type = "progressbar");
  $(".loading-chart-data").html(loader);
  $(".loading-chart-data").show();

  loader = JST["templates/loader"](loader_type = "color-spinner");
  $(".map-loader").html(loader);
  $(".inventory-loader").html(loader);
  $(".statChartHolder").hide();
  // AJAX Request
  var request = $.ajax({
    url: "/home/get_chart_data.json",
    method: "POST",
    dataType: "json",
    data: { units: units_arr, from_date: from_date, to_date:to_date },
    complete: function () {
      // Load the dashboard Map after few seconds of this ajax call completed
      setTimeout(loadMapScript,3000);
    }
  });
  request.done(function( data, textStatus, jqXHR ) {
    $("#revenue-card").show();
    $(".loading-chart-data").hide();
    load_dashboard_widget_data(data);
    load_sales_area_chart_and_table(data.sales,data.costs,data.orders.order_counts,from_date,to_date);
    load_order_src_doughnut_chart(data.orders.order_sources);
    load_order_count_bar_chart(data.orders.order_counts,data.orders.order_dates);
    load_profit_line_chart(data.costs,data.sales);
  });
  request.fail(function( jqXHR, textStatus ) {
    $("#revenue-card").hide();
    $(".loading-chart-data").show();
    $(".loading-chart-data").html("<h5 class='text-center grey-text text-darken-2'>Cannot collect revenue data, please apply filters for proper results.</h5>");
  });
}
function load_sales_area_chart_and_table(data,costs,order_counts,from_date,to_date){
  console.log (data);
  // Loading area line chart
  if(salesLineChart) {
    salesLineChart.destroy();
  }
  //process data for proper cost analysis
  var reverse_sales = data.daily_sale_amounts.reverse();
  var reverse_costs = costs.daily_costs.reverse();
  for(i=0; i<reverse_sales.length; i++){
    if (typeof reverse_costs[i] === "undefined") {
      reverse_costs.push(0);
    }
  }
  var new_sales_data = reverse_sales.reverse();
  var new_costs_data = reverse_costs.reverse();
  for(i=0; i<new_costs_data.length; i++){
    new_costs_data[i] = Math.round(new_costs_data[i]);
  }
  var lineChartData = {
    labels : data.sale_dates,
    datasets : [
      {
        label: "Sales data, group by date",
        fillColor : "rgba(128, 222, 234, 0.6)",
        strokeColor : "#80deea",
        pointColor : "#00bcd4",
        pointStrokeColor : "#ffffff",
        pointHighlightFill : "#ffffff",
        pointHighlightStroke : "#00bcd4",
        data : new_sales_data
      } ,
      {
        label: "Cost data group by date",
        fillColor : "#ffcdd2",
        strokeColor : "#ef9a9a",
        pointColor : "#e57373",
        pointStrokeColor : "#FFF",
        pointHighlightFill : "#FFF",
        pointHighlightStroke : "#ef5350",
        data: new_costs_data
      }
    ]
  }
  var ctx = $("#sales-area-canvas").get(0).getContext("2d");
  salesLineChart = new Chart(ctx).Line(lineChartData, {
    scaleShowGridLines : true,///Boolean - Whether grid lines are shown across the chart
    // scaleGridLineColor : "rgba(255,255,255,0.4)",//String - Colour of the grid lines
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
    // scaleFontColor: "#00acc1",// String - Scale label font colour
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

  // Loading tabular data
  data.order_counts = order_counts;
  data.dates = data.sale_dates;
  data.sales = new_sales_data;
  data.costs = new_costs_data;
  data.from_date = from_date;
  data.to_date = to_date;
  loader = JST["templates/dashboard/revenue_details"](data);
  $(".revenue-tabular-data").html(loader);
}

function load_order_src_doughnut_chart(data){
  if(myDoughnut) {
    myDoughnut.destroy();
  }
    var color_arr = ["#F7464A","#46BFBD","#FDB45C","#949FB1","#4D5360"];
    var hilgt_arr = ["#FF5A5E","#5AD3D1","#FFC870","#A8B3C5","#616774"];
    for(i=0;i<data.length;i++){
      data[i]['color'] = color_arr[i];
      data[i]['highlight'] = hilgt_arr[i];
    }
  var ctx = $("#order-src-canvas").get(0).getContext("2d");
  myDoughnut = new Chart(ctx).Doughnut(data, {responsive : true});
  $("#order-src-doughnut").html(" Orders from different sources");
}

function load_order_count_bar_chart(order_counts,order_dates){
  // console.log(order_counts);
  // console.log(sales.sale_dates);
  if(orderCountBarChart) {
    orderCountBarChart.destroy();
  }
  var dataBarChart = {
      labels : order_dates,
      datasets: [
          {
              label: "Order counts group by date",
              fillColor: "#46BFBD",
              strokeColor: "#46BFBD",
              highlightFill: "rgba(70, 191, 189, 0.4)",
              highlightStroke: "rgba(70, 191, 189, 0.9)",
              data: order_counts
          }
      ]
  };
  var countBarChart = $("#order-count-canvas").get(0).getContext("2d");
  orderCountBarChart = new Chart(countBarChart).Bar(dataBarChart,{
      scaleShowGridLines : false,///Boolean - Whether grid lines are shown across the chart
      showScale: true,
      animationSteps:15,
      tooltipTitleFontFamily: "'Roboto','Helvetica Neue', 'Helvetica', 'Arial', sans-serif",// String - Tooltip title font declaration for the scale label
      responsive : true
    });

}

function load_profit_line_chart(costs, sales){
  // if(profitLineChart) {
  //   profitLineChart.destroy();
  // }
  // var profit_array = [];
  // var sale_amounts = sales.daily_sale_amounts;
  // var cost_amounts = costs.daily_costs;
  // for(i=0; i<sale_amounts.length; i++){
  //   var profit = 0
  //   if (typeof cost_amounts[i] === "undefined") {
  //     var profit = sale_amounts[i];
  //   }else{
  //     var profit = (sale_amounts[i] - cost_amounts[i]);
  //   }
  //   profit_array.push(profit);
  // }
  // var lineChartData = {
  //   labels : sales.sale_dates,
  //   datasets : [
  //     {
  //       label: "Profit dataset",
  //       fillColor : "rgba(255,255,255,0)",
  //       strokeColor : "#009688",
  //       pointColor : "#00796b ",
  //       pointStrokeColor : "#fff",
  //       pointHighlightFill : "#fff",
  //       pointHighlightStroke : "#009688",
  //       data: profit_array
  //     }
  //   ]
  // }
  // var newprofitLineChart = $("#profit-line-canvas").get(0).getContext("2d");
  // profitLineChart = new Chart(newprofitLineChart).Line(lineChartData, {
  //   scaleShowGridLines : false,
  //   bezierCurve : false,
  //   scaleFontSize: 12,
  //   scaleFontStyle: "normal",
  //   // scaleFontColor: "#FFF",
  //   responsive: true,
  // });
}

function load_order_state_pie_chart(data){
    var color_arr = ["#FDB45C","#F7464A","#46BFBD","#949FB1","#4D5360"];
    var hilgt_arr = ["#FFC870","#FF5A5E","#5AD3D1","#A8B3C5","#616774"];
    for(i=0;i<data.length;i++){
      data[i]['color'] = color_arr[i];
      data[i]['highlight'] = hilgt_arr[i];
      if(data[i]['label'] == '1'){ data[i]['label'] = 'New'}
      if(data[i]['label'] == '2'){ data[i]['label'] = 'Approved'}
      if(data[i]['label'] == '3'){ data[i]['label'] = 'Preparing'}
      if(data[i]['label'] == '4'){ data[i]['label'] = 'Prepared'}
      if(data[i]['label'] == '5'){ data[i]['label'] = 'Delivered'}
      if(data[i]['label'] == '6'){ data[i]['label'] = 'Picked'}
    }
  var ctx = $("#order-status-canvas").get(0).getContext("2d");
  myPie = new Chart(ctx).Pie(data, {responsive : true});
  $("#order-state-pie").html(" Status of different orders placed today.");
}

function load_dashboard_widget_data(data) {
  console.log(data)
  // Sales Widget
  $("#total_sales_today").text(data.sales.sales_today.toFixed(1));
  var current_sales_percent = 0
  if(data.sales.sales_today > 0){
    current_sales_percent = (data.sales.sales_today)/(data.sales.daily_sale_average)*100;
  }
  $(".sales-widget-description").text(current_sales_percent.toFixed(0)+"% of average "+data.sales.daily_sale_average.toFixed(1));
  $(".sales-widget-progressbar").css({"width": current_sales_percent+"%"});

  // Orders Widget
  $("#total_orders_today").text(data.orders.orders_today);
  var current_order_percent = 0
  if(data.orders.orders_today > 0){
    current_order_percent = (data.orders.orders_today)/(data.orders.order_average)*100;
  }
  $(".orders-widget-description").text(current_order_percent.toFixed(0)+"% of average "+data.orders.order_average.toFixed(0));
  $(".orders-widget-progressbar").css({"width": current_order_percent+"%"});

  // Costs Widget
  $("#total_costs_today").text(data.costs.cost_today);
  var current_cost_percent = 0
  if(data.costs.cost_today > 0){
    current_cost_percent = (data.costs.cost_today)/(data.costs.daily_cost_average)*100;
  }
  $(".cost-widget-description").text(current_cost_percent.toFixed(0)+"% of average "+data.costs.daily_cost_average.toFixed(0));
  $(".cost-widget-progressbar").css({"width": current_cost_percent+"%"});

   // Costs Widget
  // $("#total_costs_today").text(data.sales.sales_today.toFixed(1));
  // var daily_sales_percent = 0
  // var daily_sales_target = parseInt(data.sales.daily_sales_target);
  // if(data.sales.sales_today > 0){
  //   daily_sales_percent = (data.sales.sales_today)/(daily_sales_target)*100;
  // }
  // $(".cost-widget-description").text(daily_sales_percent.toFixed(0)+"% of target sale "+daily_sales_target.toFixed(0));
  // $(".cost-widget-progressbar").css({"width": daily_sales_percent+"%"});
}
// Google map related functions
// ****************************
function loadMapScript() {
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.id = "google-map-script"
  script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp' +
      '&signed_in=true&callback=initialize_map';
  if ( $( "#google-map-script" ).length) {
    initialize_map();
  }else{
    document.body.appendChild(script);
  }
}
function initialize_map() {
  //Build units array
  var units_arr = new Array;
  $(".units-checkbox:checked").each(function(index) {
    val = $(this).attr('id');
    units_arr.push(val);
  });
  var from_date = $("#from_date").val();
  var to_date = $("#to_date").val();

  var map_request = $.ajax({
    url: "/home/get_map_data.json",
    method: "GET",
    dataType: "json",
    data: { units: units_arr, from_date: from_date, to_date:to_date },
    complete: function () {
      // Load the inventory report after few seconds of this ajax call completed
      // setTimeout(loadInventoryReport,3000);
    }
  });
  map_request.done(function( data, textStatus, jqXHR ) {

    $(".map-unit-details").hide();
    if(data.unit_sales_data.units.length > 0){
      $(".polar-chart-container").show();
      $(".sales-details-tabular-data").html("");
      load_today_sale_bar_chart(data.unit_data);
      load_units_revenue_polar_chart(data.unit_sales_data);
      load_sales_analysis_tabular_data(data.unit_sales_data,from_date,to_date);
    }else{
      $(".polar-chart-container").hide();
    }

    //Draw Map
    window.map = new google.maps.Map(document.getElementById('map-canvas'), {
        styles: [{"featureType":"landscape.man_made","elementType":"geometry","stylers":[{"color":"#f7f1df"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#d0e3b4"}]},{"featureType":"landscape.natural.terrain","elementType":"geometry","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"poi.business","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.medical","elementType":"geometry","stylers":[{"color":"#fbd3da"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#bde6ab"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"labels","stylers":[{"visibility":"off"}]},{"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#ffe15f"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#efd151"}]},{"featureType":"road.arterial","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},{"featureType":"road.local","elementType":"geometry.fill","stylers":[{"color":"black"}]},{"featureType":"transit.station.airport","elementType":"geometry.fill","stylers":[{"color":"#cfb2db"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#a2daf2"}]}]
    });

    var infowindow = new google.maps.InfoWindow();

    var bounds = new google.maps.LatLngBounds();
    data = data.units
    for (i = 0; i < data.length; i++) {
        marker = new google.maps.Marker({
            position: new google.maps.LatLng(data[i]['latitude'], data[i]['longitude']),
            map: map
        });

        bounds.extend(marker.position);

        google.maps.event.addListener(marker, 'click', (function (marker, i) {
            return function () {
              infowindow.setContent(data[i]['unit_name']);
              infowindow.open(map, marker);
              load_unit_map_data(data[i]['id']);
            }
        })(marker, i));
    }

    map.fitBounds(bounds);

    var listener = google.maps.event.addListener(map, "idle", function () {
        // map.setZoom(3);
        google.maps.event.removeListener(listener);
    });
  });
  map_request.fail(function( jqXHR, textStatus ) {
    console.log( "Failed to load map markers. Error: " + textStatus );
  });
}

function load_unit_map_data (unit_id) {
  $(".polar-chart-container").hide();
  $(".map-unit-details").show();
  var from_date = $("#from_date").val();
  var to_date = $("#to_date").val();
  var map_unit_request = $.ajax({
    url: "/home/get_map_data.json",
    method: "GET",
    dataType: "json",
    data: {units: [unit_id], unit_id: unit_id, from_date: from_date, to_date:to_date}
  });
  map_unit_request.done(function( data, textStatus, jqXHR ) {
    $(".sales-details-tabular-data").html("");

    if(data.unit_sales_data.units.length > 0){
      load_sales_analysis_tabular_data(data.unit_sales_data,from_date,to_date);
    }
    content = build_map_unit_quick_info(data.unit_data);
    $(".map-unit-details").html(content);
    var $ppc = $('.unit-progress-pie-chart'),
    percent = parseInt($ppc.data('percent')),
    deg = 360*percent/100;
    if (percent > 50) {
      $ppc.addClass('unit-gt-50');
    }
    $('.unit-ppc-progress-fill').css('transform','rotate('+ deg +'deg)');
    $('.unit-ppc-percents span').html(percent+'%');
    build_map_unit_sparkline_content (data.unit_data);
  });
  map_unit_request.fail(function( jqXHR, textStatus ) {
    alert( "Failed to load unit data. Error: " + textStatus );
  });
}

function load_units_revenue_polar_chart(units_sales_data) {
  if(polarRevenueChart) {
    polarRevenueChart.destroy();
  }
  data = [];
  var color_arr = ["#FDB45C","#F7464A","#46BFBD","#949FB1","#4D5360"];
  var hilgt_arr = ["#FFC870","#FF5A5E","#5AD3D1","#A8B3C5","#616774"];
  for(i=0; i < units_sales_data.units.length; i++){
    data_obj = {};
    data_obj['value'] = units_sales_data.sale_amounts[i];
    data_obj['label'] = units_sales_data.units[i].unit_name;
    data_obj['color'] = color_arr[i];
    data_obj['highlight'] = hilgt_arr[i];
    data.push(data_obj);
  }

  var prce = $("#units-polar-chart").get(0).getContext("2d");
  polarRevenueChart = new Chart(prce).PolarArea(data, {
    segmentStrokeWidth : 1,
    responsive:true
  });
}
// Todat sales target
function load_today_sale_bar_chart(sale){
  var daily_sales_target = parseInt(sale.daily_sales_target);
  var today_sale = parseInt(sale.sales_today);
  var persentage = (today_sale/daily_sales_target)*100;
  if (isNaN(persentage)){
    $(".statChartHolder").hide();
  }else{
  $(".statChartHolder").show();
  var $ppc = $('.progress-pie-chart'),
    percent = parseInt(persentage),
    deg = 360*percent/100;
    if (percent > 50) {
      $ppc.addClass('gt-50');
    }
    $('.ppc-progress-fill').css('transform','rotate('+ deg +'deg)');
    $('.ppc-percents span').html(percent+'%');
    $('.text').html('Today\'s Sales Target');
    $('.value').html(daily_sales_target);
  }
}

function load_sales_analysis_tabular_data(sales_data,from_date,to_date){
  // Loading tabular data
  sales_data.sales_data = sales_data;
  sales_data.from_date = from_date;
  sales_data.to_date = to_date;
  load_data = JST["templates/dashboard/sales_details"](sales_data);
  $(".sales-details-tabular-data").html(load_data);
}

function build_map_unit_quick_info(data) {
  var daily_sales_target = parseInt(data.daily_sales_target);
  var today_sale = parseInt(data.sales_today);
  var persentage = (today_sale/daily_sales_target)*100;
  contentStr = '<div class="description-block margin-bottom">'
  contentStr += '<div class="sales_sparkbar padding-10"></div>'
  contentStr += '<h5 class="description-header" style="color:#FFF">'+data.sales_today+'</h5>'
  contentStr += '<span class="description-text">Total Sales Today</span>'
  contentStr += '</div>'
  contentStr += '<div class="description-block margin-bottom">'
  contentStr += '<div class="order_sparkbar padding-10"></div>'
  contentStr += '<h5 class="description-header" style="color:#FFF">'+data.orders_today+'</h5>'
  contentStr += '<span class="description-text">Number of Orders Today</span>'
  contentStr += '</div>'
  // contentStr += '<div class="description-block margin-bottom">'
  // contentStr += '<div class="revenue_sparkbar padding-10"></div>'
  // contentStr += '<h5 class="description-header" style="color:#FFF">'+data.cost_today+'</h5>'
  // contentStr += '<span class="description-text">Total Cost Today</span>'
  // contentStr += '</div>'
  if (isNaN(persentage)){
    contentStr += '<div class="description-block margin-bottom">'
    contentStr += '</div>'
  }else{
    contentStr += '<div class="description-block margin-bottom">'
    contentStr += '<div class="unit-statChartHolder">'
    contentStr += '<div class="unit-progress-pie-chart" data-percent='+persentage+'>'
    contentStr += '<div class="unit-ppc-progress">'
    contentStr += '<div class="unit-ppc-progress-fill"></div>'
    contentStr += '</div>'
    contentStr += '<div class="unit-ppc-percents">'
    contentStr += '<div class="unit-pcc-percents-wrapper">'
    contentStr += '<span>%</span>'
    contentStr += '<label class="text">Today\'s Sales Target</label>'
    contentStr += '</br>'
    contentStr += '<label class="value">'+data.daily_sales_target+'</label>'
    contentStr += '</div>'
    contentStr += '</div>'
    contentStr += '</div>'
    contentStr += '</div>'
    contentStr += '</div>'
  }
  return contentStr;
}

function build_map_unit_sparkline_content (data) {
  sales_values = new Array();
  order_values = new Array();
  cost_values = new Array();
  for (var i = 0; i < data.sales_history.length; i++) {
    sales_values.push(data.sales_history[i]['total_price']);
  };
  for (var i = 0; i < data.order_history.length; i++) {
    order_values.push(data.order_history[i]['order_count']);
  };
  for (var i = 0; i < data.cost_history.length; i++) {
    cost_values.push(data.cost_history[i]);
  };
  $('.sales_sparkbar').sparkline(sales_values, {type: 'bar', barColor: 'white', height: '40'} );
  $('.order_sparkbar').sparkline(order_values, {type: 'bar', barColor: 'white', height: '40'} );
  $('.revenue_sparkbar').sparkline(cost_values, {type: 'bar', barColor: 'white', height: '40'} );
}

// Inventory related functions
// ****************************
function loadInventoryReport(){
  //Building units/locations array
  var units_arr = new Array;
  $(".units-checkbox:checked").each(function(index) {
    val = $(this).attr('id');
    units_arr.push(val);
  });
  var from_date = $("#from_date").val();
  var to_date = $("#to_date").val();

  // AJAX Request
  var request = $.ajax({
    url: "/home/get_inventory_data.json",
    method: "GET",
    dataType: "json",
    data: { units: units_arr, from_date: from_date, to_date:to_date },
  });
  request.done(function( data, textStatus, jqXHR ) {
    console.log()
  });
  request.fail(function( jqXHR, textStatus ) {
    alert(textStatus);
  });
}
