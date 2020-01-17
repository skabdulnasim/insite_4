$(document).ready(function() {
  $('#applyRecursion').unbind('click').click(function(){
    var vendor_id = $('#vendorId').html();
    var executive_id = $('#executiveId').html();
    var visiting_date = $('#date').html();
    var recursion_rule = $('#recursionRule').find(":selected").text();
    var recursion_duration =  $('#duration').val();
    console.log(vendor_id, executive_id , visiting_date , recursion_rule , recursion_duration);
    recursive_allocation = $.ajax({
      method : 'post',
      url : '/sourcing_executives/create_recursive_allocation',
      dataType: "json",
      data: { user_id : executive_id , vendor_id : vendor_id, visit_date : visiting_date,recursion_rule:$('#recursionRule').find(":selected").data('id'), duration:recursion_duration}
    });
    recursive_allocation.done(function(data,textStatus,jqXHR){
      console.log(data);
      $('#calendar').fullCalendar('destroy');
      fetch_allocation_data(executive_id,visiting_date);
    });
    recursive_allocation.fail(function(textStatus , jqXHR){
      console.log('faild in ajax'); 
    });
  });

  $("#RemoveByDate").unbind('click').click(function(){
    if($("#start_date").val()=="" || $("#end_date").val()==""){
      alert("please provide date range");
    }else{
      $(".preloader").css("display","block");
      remove_all_by_date = $.ajax({
        url:"/sourcing_executives/remove_all_by_date",
        method:"post",
        dataType:"json",
        data:{user_id:$('#executiveId').html(),from_date:$("#start_date").val(),to_date:$("#end_date").val()}
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
      url: "/sourcing_executives/remove_allocation",
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

  $(".loadallocation").unbind('click').click(function(){
    var render_date = new Date().toJSON().slice(0,10);
    var executive_id = $(this).data('id');
    $('#executiveId').html(executive_id);
    $("#user_name").html($(this).data('user_name'));
    $('#calendar').fullCalendar('destroy');
    fetch_allocation_data(executive_id,render_date);
  });
  function fetch_allocation_data(executive_id ,render_date){ 
    var event_data;
  //ajax call to get all allocations
    allocation = $.ajax({
      method : "GET", 
      url : "/sourcing_executives/get_allocations",
      dataType : "json",
      data : {user_id : executive_id}
    });
    allocation.done(function(data , textStatus , jqXHR){
      event_data = data.data;
      loadCalendar(event_data,executive_id ,render_date);
    });
    allocation.fail(function(jqXHR , textStatus){ 
      alert('some error occured while fetching executive allocations');  
    });
  }
  function loadCalendar(event_data,executive_id ,render_date){
    console.log(event_data);
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
  //   /* initialize the calendar
  //   -----------------------------------------------------------------*/
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
      events : event_data,
      eventLimit: 2 ,
      eventLimitText: "More Allocations",
      drop: function(date , allDay) {
           
        console.log(executive_id);
        console.log($(this).data("id"));    
        var render_date = $('#calendar').fullCalendar('getDate');
        render_date = render_date.format("YYYY-MM-DD");
        $('#external-events .fc-event').each(function() {
          $(this).data('event', {
              stick: true 
            }); 
        });
        var vendor_id  = $(this).data("id")
        visiting_date = (date.format());
        create_allocation = $.ajax({
          method : "POST" , 
          url : "/sourcing_executives/create_allocation",
          dataType: "json",
          data: { user_id : executive_id , vendor_id : vendor_id, visit_date : visiting_date},
        });
        create_allocation.done(function(data , textStatus , jqXHR){
          if (data.status=="ok"){ 
            console.log(data);
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(executive_id,render_date);
            $('#recursionModal').modal();
            $('#vendorId').html(vendor_id);
            $('#executiveId').html(executive_id);
            $('#date').html(date.format()); 
            // render_calendar(render_date,executive_id);
          } else{
            alert("duplicate allocation can not be created");
            Materialize.toast("This resource has been allocated already", 4000, "red");
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(executive_id,render_date);
          }
        });
        create_allocation.fail(function(jqXHR, textStatus){
          alert("allocation creation faild");
          $('#calendar').fullCalendar('destroy');
          fetch_allocation_data(executive_id,render_date);
        });
      },    
      eventClick: function(calEvent, jsEvent, view) {
        console.log(calEvent.title);
        console.log(calEvent.start);
        console.log(calEvent.id);
        // $('#modalTitle').html(calEvent.title);
        // $('#calendarModal').modal();
      },
      eventDrop: function(event, delta, revertFunc, jsEvent, ui, view) {
        var new_date =event.start.format();
        update_allocation = $.ajax({
          url: " /sourcing_executives/update_allocation",
          method: "post",
          dataType: "json",
          data: {id: event.id, visit_date: new_date}
        });
        update_allocation.done(function(data, textStatus, jqXHR){
          console.log(data);
          if(data.status == "ok"){
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(executive_id, new_date);            
          }else{
            alert("duplicate allocation can't be created");
            $('#calendar').fullCalendar('destroy');
            fetch_allocation_data(executive_id ,new_date);
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
          // if(confirm("are you sure you want to delete the allocation?")){
          //   allocation_date =moment(event.start).format("YYYY-MM-DD");
          //   remove_allocation = $.ajax({
          //     url: "/sourcing_executives/remove_allocation",
          //     method:"post",
          //     dataType :"json",
          //     data: {id:event.id}
          //   });
          //   remove_allocation.done(function(data, textStatus, jqXHR){
          //     $('#calendar').fullCalendar('removeEvents',event._id);
          //   });
          //   remove_allocation.fail(function(textStatus,jqXHR){
          //     alert("faild to delete");
          //   });
          // }
        }); 
      },
      eventAfterRender: function(event, element, view) {
        $(element).css('height','28px');
        $(element).css('margin-bottom','5px');
      }     
    });
  }

  $(document).on("click", ".inspection_row", function() {
    var handler, inspection_id, lat_long_array, request, vendor_address, vendor_infowindow, vendor_lat_long_array, vendor_latitude, vendor_longitude, vendor_name, executive_address, executive_infowindow, executive_lat_long_array, executive_latitude, executive_longitude, executive_name, user_inspection_discussion, user_inspection_lat_long_array, user_inspection_latitude, user_inspection_longitude;
    user_inspection_latitude = $(this).data('user-inspection-lat');
    user_inspection_longitude = $(this).data('user-inspection-long');
    vendor_latitude = $(this).data('vendor-lat');
    vendor_longitude = $(this).data('vendor-long');
    executive_latitude = $(this).data('executive-lat');
    executive_longitude = $(this).data('executive-long');
    inspection_id = $(this).data('inspection-id');
    executive_address = $(this).data('executive-address');
    vendor_address = $(this).data('vendor-address');
    vendor_name = $(this).data('vendor-name');
    executive_name = $(this).data('executive-name');
    user_inspection_discussion = $(this).data('user-inspection-discussion');

    lat_long_array = [];
    request = $.ajax({
      type: 'GET',
      url: "/api/v2/inspections/" + inspection_id,
      dataType: "json"
    });
    request.done(function(responseData, textStatus, jqXHR) {
      var data, result;
      data = responseData.data;
      if (data.inspection_questions.length > 0) {
        data.response = data;
        result = JST["templates/inspections/question_answer_details"](data);
        $("#inspection_ques_" + inspection_id).html(result);
      }
    });
    request.error(function(jqXHR, textStatus, errorThrown) {
      Materialize.toast("AJAX Error", 5000);
    });

    if (typeof user_inspection_latitude !== 'undefined' && typeof user_inspection_longitude !== 'undefined') {
      user_inspection_lat_long_array = {
        "lat": user_inspection_latitude,
        "lng": user_inspection_longitude,
        "picture": {
          "url": "/assets/icons/inspection.svg",
          "width": 45,
          "height": 45
        },
        "infowindow": "" + user_inspection_discussion
      };
      lat_long_array.push(user_inspection_lat_long_array);
    }
    vendor_infowindow = "<div class='float-l'><i class='fa fa-bank'></i> &nbsp" + vendor_name + "</div><br/><br/><div class='float-l'><i class='fa fa-map-marker'></i> &nbsp" + vendor_address + "</div>";
    if (typeof vendor_latitude !== 'undefined' && typeof vendor_longitude !== 'undefined') {
      vendor_lat_long_array = {
        "lat": vendor_latitude,
        "lng": vendor_longitude,
        "picture": {
          "url": "/assets/icons/ic_marker_subStore.svg",
          "width": 45,
          "height": 45
        },
        "infowindow": "" + vendor_infowindow
      };
      lat_long_array.push(vendor_lat_long_array);
    }
    executive_infowindow = "<div class='float-l'><i class='fa fa-user'></i> &nbsp" + executive_name + "</div><br/><br/><div class='float-l'><i class='fa fa-map-marker'></i> &nbsp" + executive_address + "</div>";
    if (typeof executive_latitude !== 'undefined' && typeof executive_longitude !== 'undefined') {
      executive_lat_long_array = {
        "lat": executive_latitude,
        "lng": executive_longitude,
        "picture": {
          "url": "/assets/icons/ic_marker_salesboy.svg",
          "width": 45,
          "height": 45
        },
        "infowindow": "" + executive_infowindow
      };
      lat_long_array.push(executive_lat_long_array);
    }
    handler = Gmaps.build('Google');
    handler.buildMap({
      provider: {},
      internal: {
        id: "inspections_map_" + inspection_id
      }
    }, function() {
      var i, k, markers, ref;
      for (k = i = 0, ref = lat_long_array.length - 1; 0 <= ref ? i <= ref : i >= ref; k = 0 <= ref ? ++i : --i) {
        markers = handler.addMarkers([lat_long_array[k]]);
      }
      handler.bounds.extendWith(markers);
      handler.fitMapToBounds();
      return handler.getMap().setZoom(9);
    });
  });

  $(document).on("click", ".fancybox", function(e) {
    var inspection_question_id;
    inspection_question_id = $(this).data('inspection-question-id');
    $(".fancybox_" + inspection_question_id).fancybox({
      openEffect: 'none',
      closeEffect: 'none'
    });
    return e.preventDefault();
  });

});