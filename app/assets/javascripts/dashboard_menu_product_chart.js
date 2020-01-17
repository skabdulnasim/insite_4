$.fn.menu_products =function(){	
	$("#sale_chart").html("");
	var margin = {top: 20, right: 20, bottom: 150, left: 40},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
	    .rangeRoundBands([0, width], .9);
	
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
	    return "<strong>Quantity:</strong> <span style='color:red'>" + d.total_sale_quantity + "</span>";
	  });	
	
	var svg = d3.select("#sale_chart").append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	    .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
			
	
	d3.json("/dashboard.json", function(error, data) {
		  	
		  x.domain(data.menu_product_sales_quantity.map(function(d) { return d.product_id; }));
		  y.domain([0, d3.max(data.menu_product_sales_quantity, function(d) { return d.total_sale_quantity; })]);

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
		      .text("Quantity");
		
		  svg.selectAll(".bar")
		      .data(data.menu_product_sales_quantity)
		    .enter().append("rect")
		      .attr("class", "bar")
		      .attr("x", function(d) { return x(d.product_id); })
		      .attr("width", 30)
		      .attr("y", function(d) { return y(d.total_sale_quantity); })
		      .attr("height", function(d) { return height - y(d.total_sale_quantity); })
		      .on('mouseover', tip.show)
		      .on('mouseout', tip.hide)	
		
		});
		
		function type(d) {
		  d.total_sale_quantity = +d.total_sale_quantity;
		  return d;
		}
	$("#total_sale").change(function(){
		$("#sale_chart").html("");
		var selected = $(this).val();
		if(selected == "" || selected == "quantity"){
			var margin = {top: 20, right: 20, bottom: 150, left: 40},
		    width = 960 - margin.left - margin.right,
		    height = 500 - margin.top - margin.bottom;

			var x = d3.scale.ordinal()
			    .rangeRoundBands([0, width], .9);
			
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
			    return "<strong>Quantity:</strong> <span style='color:red'>" + d.total_sale_quantity + "</span>";
			  });	
			
			var svg = d3.select("#sale_chart").append("svg")
			    .attr("width", width + margin.left + margin.right)
			    .attr("height", height + margin.top + margin.bottom)
			    .append("g")
			    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
								
			d3.json("/dashboard.json", function(error, data) {
				  	
				  x.domain(data.menu_product_sales_quantity.map(function(d) { return d.product_id; }));
				  y.domain([0, d3.max(data.menu_product_sales_quantity, function(d) { return d.total_sale_quantity; })]);

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
				      .text("Quantity");
				
				  svg.selectAll(".bar")
				      .data(data.menu_product_sales_quantity)
				    .enter().append("rect")
				      .attr("class", "bar")
				      .attr("x", function(d) { return x(d.product_id); })
				      .attr("width", 30)
				      .attr("y", function(d) { return y(d.total_sale_quantity); })
				      .attr("height", function(d) { return height - y(d.total_sale_quantity); })
				      .on('mouseover', tip.show)
				      .on('mouseout', tip.hide)	
				
				});
				
				function type(d) {
				  d.total_sale_quantity = +d.total_sale_quantity;
				  return d;
				}		
		}
		if(selected == "price"){
			$("#sale_chart").html("");
			var margin = {top: 20, right: 20, bottom: 150, left: 40},
		    width = 960 - margin.left - margin.right,
		    height = 500 - margin.top - margin.bottom;
			var x = d3.scale.ordinal()
			    .rangeRoundBands([0, width], .9);			
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
			    return "<strong>Price:</strong> <span style='color:red'>" + d.total_sale + "</span>";
			  })	

			var svg = d3.select("#sale_chart").append("svg")
			    .attr("width", width + margin.left + margin.right)
			    .attr("height", height + margin.top + margin.bottom)
			    .append("g")
			    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
			svg.call(tip);
			d3.json("/dashboard.json", function(error, data) {				
			  x.domain(data.menu_product_sales_price.map(function(d) { return d.product_id; }));
			  y.domain([0, d3.max(data.menu_product_sales_price, function(d) { return d.total_sale; })]);			
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
			      .text("Price");			
			  svg.selectAll(".bar")
			      .data(data.menu_product_sales_price)
			    .enter().append("rect")
			      .attr("class", "bar")
			      .attr("x", function(d) { return x(d.product_id); })
			      .attr("width", 30)
			      .attr("y", function(d) { return y(d.total_sale); })
			      .attr("height", function(d) { return height - y(d.total_sale); })			
			      .on('mouseover', tip.show)
			      .on('mouseout', tip.hide)	

			});			
			function type(d) {
			  d.total_sale = +d.total_sale;
			  return d;
			}			
		}
	})		
}