$(document).ready(function() {
	$('#applyRecursion').unbind('click').click(function(){
    var resource_id = $('#resourceId').html();
    var sale_person_id = $('#sale_person_Id').html();
    var visiting_date = $('#date').html();
    var recursion_rule = $('#recursionRule').find(":selected").text();
    var recursion_duration =  $('#duration').val();
    recursive_allocation = $.ajax({
      method : 'post',
      url : '/sales_persons/create_recursive_allocation',
      dataType: "json",
      data: { user_id : sale_person_id , resource_id : resource_id, visit_date : visiting_date,recursion_rule:recusion_rule_id, duration:recursion_duration}
    });
    recursive_allocation.done(function(data,textStatus,jqXHR){
      $('#calendar').fullCalendar('destroy');
      fetch_allocation_data(sale_person_id,visiting_date);
    });
    recursive_allocation.fail(function(textStatus , jqXHR){
      Materialize.toast("ajax request faild in recursive allocations", 4000, "red"); 
    });
  });
  $("#RemoveByDate").unbind('click').click(function(){
    if($("#start_date").val()=="" || $("#end_date").val()==""){
      alert("please provide date range");
    }else{
      $(".preloader").css("display","block");
      remove_all_by_date = $.ajax({
        url:"/sales_persons/remove_all_by_date",
        method:"post",
        dataType:"json",
        data:{user_id:$('#sale_person_Id').html(),from_date:$("#start_date").val(),to_date:$("#end_date").val()}
      });
      remove_all_by_date.done(function(data,textStatus,jqXHR){
        data.data.map(function(id){
          $('#calendar').fullCalendar('removeEvents',id);
        });
        $(".preloader").css("display","none");
      });
      remove_all_by_date.fail(function(textStatus,jqXHR){
        $(".preloader").css("display","none");
        alert("faild to delete");
      });
  }
  });

  $("#applyRemove").unbind('click').click(function(){
    if($("#from_date").val()=="" || $("#to_date").val()==""){
        var param_data= {id:$("#allocationId").html()};
    }else{
        var param_data= {id:$("#allocationId").html(),from_date:$("#from_date").val(),to_date:$("#to_date").val()};
    }
    $(".preloader").css("display","block");
    remove_allocation = $.ajax({
      url: "/sales_persons/remove_allocation",
      method:"post",
      dataType :"json",
      data: param_data
    });
    remove_allocation.done(function(data, textStatus, jqXHR){
      data.data.map(function(id){
        $('#calendar').fullCalendar('removeEvents',id);
      });
      $(".preloader").css("display","none");
    });
    remove_allocation.fail(function(textStatus,jqXHR){
      $(".preloader").css("display","none");
      alert("faild to delete");
    });
  });

	$('.calendar_view').unbind('click').click(function(){
    $(".preloader").css("display","block");
		var sale_person_id = $(this).data("sale-person-id");
    $('#sale_person_Id').html(sale_person_id);
		var render_date = new Date().toJSON().slice(0,10);
		$("#user_name").html($(this).data('sale_person'));
		$('#calendar').fullCalendar('destroy');
		fetch_allocation_data(sale_person_id,render_date)


	});
	function fetch_allocation_data(sale_person_id ,render_date){ 
    
    var event_data=[];
    var visit_month = new Date(render_date)
    visit_month = visit_month.getMonth()+1
    // ajax call to get all allocations
    allocation = $.ajax({
      method : "GET", 
      url : "/sales_persons/get_allocations",
      dataType : "json",
      data : {user_id : sale_person_id,visit_month:visit_month}
    });
    allocation.done(function(data , textStatus , jqXHR){

      event_data = data.data;
      loadCalendar(event_data,sale_person_id ,render_date);

    });
    allocation.fail(function(jqXHR , textStatus){ 
      alert("some errors occured while fetching sale person's allocations");  
    });
    $(".preloader").css("display","none");
  }
	function loadCalendar(event_data,sale_person_id ,render_date){
	  /* initialize the external events
	  -----------------------------------------------------------------*/
    $('#external-events .fc-event').each(function() {
      // store data so the calendar knows to render an event upon drop
      $(this).data('event', {
          title: $.trim($(this).text()), // use the element's text as the event title
          stick: false 
      });

      // make the event draggable using jQuery UI
      $(this).draggable({
          zIndex: 999,
          revert: true,      // will cause the event to go back to its
          revertDuration: 0  //  original position after the drag
      });
    });
	  /*  initialize the calendar
	   -----------------------------------------------------------------*/
    $('#calendar').fullCalendar({
      header: {
          left: 'prev,next today',
          center: 'title',
          right: 'month,agendaWeek,agendaDay'
      },
      height: 650,
      defaultDate:render_date ,
      editable: false,
      eventStartEditable  : true,
      droppable: true, // this allows things to be dropped onto the calendar
      dragRevertDuration: 0,
      events :event_data,
      eventLimit: 2 ,
      eventLimitText: "More Allocations",
      drop: function(date , allDay) {     
        var render_date = $('#calendar').fullCalendar('getDate');
        render_date = render_date.format("YYYY-MM-DD");
        $('#external-events .fc-event').each(function() {
          $(this).data('event', {
              stick: true 
            }); 
        });
        var resource_id  = $(this).data("id")
        visiting_date = (date.format());
        create_allocation = $.ajax({
          method : "POST" , 
          url : "/sales_persons/create_allocation",
          dataType: "json",
          data: { user_id : sale_person_id , resource_id : resource_id, visit_date : visiting_date},
        });
        create_allocation.done(function(data , textStatus , jqXHR){
          if (data.status=="ok"){ 
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(sale_person_id,render_date);
            $('#recursionModal').modal();
            $('#resourceId').html(resource_id);
            $('#sale_person_Id').html(sale_person_id);
            $('#date').html(date.format());
          } else{
            alert("duplicate allocation can not be created");
            Materialize.toast("This resource has been allocated already", 4000, "red");
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(sale_person_id,render_date);
          }
        });
        create_allocation.fail(function(jqXHR, textStatus){
          alert("allocation creation faild");
          $('#calendar').fullCalendar('destroy');
          fetch_allocation_data(sale_person_id,render_date);
        });
      },    
      eventClick: function(calEvent, jsEvent, view) {
        console.log(calEvent.start._i);
        console.log(calEvent.id);
        console.log(sale_person_id);
      },
      eventDrop: function(event, delta, revertFunc, jsEvent, ui, view) {
        var new_date =event.start.format();
        update_allocation = $.ajax({
          url: " /sales_persons/update_allocation",
          method: "post",
          dataType: "json",
          data: {id: event.id, visit_date: new_date}
        });
        update_allocation.done(function(data, textStatus, jqXHR){
          if(data.status == "ok"){
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(sale_person_id, new_date);            
          }else{
            alert("duplicate allocation can't be created");
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(sale_person_id ,new_date);
          }
        });
        update_allocation.fail(function(){
          alert("allocation update faild");
        });
      },        
      eventRender: function(event, element) { 
       element.find(".fc-bg").css("pointer-events","none");
       element.append("<div style='position:absolute;bottom:2px;right:0px' ><button type='button' id='btnDeleteEvent' class='btn btn-block btn-danger btn-flat'>X</button></div>" );
       element.find("#btnDeleteEvent").click(function(){
          $("#allocationId").html(event.id)
          $("#from_date").val(event.start._i);
          $("#to_date").val("");
          $('#DateRangeRemoveModal').modal();
        }); 
      },
      eventAfterRender: function(event, element, view) {
        $(element).css('height','28px');
        $(element).css('margin-bottom','5px');
      }     
    });
    $(".fc-more").click(function(){
    });
  }
});
