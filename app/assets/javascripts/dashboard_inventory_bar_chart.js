$.fn.inventory_product = function(){
	
	var margin = {top: 30, right: 20, bottom: 150, left: 40},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
	    .rangeRoundBands([0, width], .8);
	
	var y = d3.scale.linear()
	    .range([height, 0]);
	
	var xAxis = d3.svg.axis()
	    .scale(x)
	    .orient("bottom");
	
	var yAxis = d3.svg.axis()
	    .scale(y)
	    .orient("left")
	    .ticks(10);
	
	var tip = d3.tip()
	  .attr('class', 'd3-tip')
	  .offset([-10, 0])
	  .html(function(d) {
	    return "<strong>Stock:</strong> <span style='color:red'>" + d.current_stock + "</span>";
	  });	
	
	var svg = d3.select("#chartdiv").append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	    .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	
		
	
	d3.json("/dashboard.json", function(error, data) {	
	  	
	  x.domain(data.product_stock.map(function(d) { return d.name; }));
	  y.domain([0, d3.max(data.product_stock, function(d) { return d.current_stock; })]);
	
	  svg.call(tip);
	  
	  svg.append("g")
	      .attr("class", "x axis")
	      .attr("transform", "translate(0," + height + ")")
	      .call(xAxis)
	  	  .selectAll("text")
	  	  .style("text-anchor", "end")
	  	  .attr("dx", "-.8em")
	  	  .attr("dy", ".15em")
	  	  .attr("transform", function(d) {
	        return "rotate(-65)" 
	  	  });
	  	  
	  svg.append("g")
	      .attr("class", "y axis")
	      .call(yAxis)
	      .append("text")
	      .attr("transform", "rotate(-90)")
	      .attr("y", 6)
	      .attr("dy", ".71em")
	      .style("text-anchor", "end")
	      .text("Stock");
	
	  svg.selectAll(".bar")
	      .data(data.product_stock)
	    .enter().append("rect")
	      .attr("class", "bar")
	      .attr("x", function(d) { return x(d.name); })
	      .attr("width", 30)
	      .attr("y", function(d) { return y(d.current_stock); })
	      .attr("height", function(d) { return height - y(d.current_stock); })
	      .on('mouseover', tip.show)
	      .on('mouseout', tip.hide)	
	});
	
	function type(d) {
	  d.product_stock.current_stock = +d.product_stock.current_stock;
	  return d;
	}
}	