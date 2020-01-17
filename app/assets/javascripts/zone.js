$(document).ready(function() {
  var role_id = $("#allocted_role_id").data("role-id");
  if(role_id != undefined){
    $("#role_id > option").each(function() {
      if($(this).val() == role_id){
        $(this).attr("selected","selected");
        load_user_by_role(role_id);
      }
    });
  }
  $("#role_id").on("click", function() {
    var role_id;
    role_id = $(this).val();
    $('#ajax-user-section').html('');
    if (role_id.length > 0) {
     load_user_by_role(role_id);
    } else {
      $('#ajax-user-section_for_zone').html('');
    }
  });
  
  $(document).on("change", "#users", event, function() {
    $("#user_id").val($("#users option:selected").val());
  });
  function load_user_by_role(role_id){
   var request;
   var zone_id = $("#zone_id").data('zone-id') == undefined ? '' : $("#zone_id").data('zone-id')
   request = $.ajax({
      url: "/zones/fetch_users.json?role=" + role_id + "&zone_id="+zone_id
    });
    request.done(function(data, textStatus, jqXHR) {
      var result;
      data.type_info = data;
      data.present_user_id = $("#user_id").val()
      result = JST["templates/zones/select_user"](data);
      $("#ajax-user-section_for_zone").html(result);
    });
    request.error(function(jqXHR, textStatus, errorThrown) {
      $('#ajax-user-section_for_zone').html('');
    });
  }
});

