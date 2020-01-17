//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// THEME DEFAUL JS //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
$(function() {
  $('#side-menu').metisMenu();
  get_notifications(1);
});

// Allow numeric entry only
$(document).on("keydown", ".allow-numeric-only", function(event) {
  if (event.shiftKey === true) {
    event.preventDefault();
  }
  if (event.keyCode >= 48 && event.keyCode <= 57 || event.keyCode == 17 || event.keyCode == 17 || event.keyCode >= 96 && event.keyCode <= 105 || event.keyCode === 8 || event.keyCode === 9 || event.keyCode === 37 || event.keyCode === 39 || event.keyCode === 46 || event.keyCode === 190) {

  } else {
    event.preventDefault();
  }
  if ($(this).val().indexOf('.') !== -1 && event.keyCode === 190) {
    event.preventDefault();
  }
});

// Checkbox Toggle Function
$(document).on("click", ".checkbox-parent-toggle", function() {
	if (this.checked) {
	  $(".checkbox-child").prop('checked', true);
	  $(".check-input").prop('required', true);
	} else {
	  $(".checkbox-child").prop('checked', false);
	  $(".check-input").prop('required', false);
	}
});

$(document).on("click", ".parent-checkbox-toggle", function() {
  if (this.checked) {
    $(".child-checkbox").prop('checked', true);
    $(".check-input").prop('required', true);
  } else {
    $(".child-checkbox").prop('checked', false);
    $(".check-input").prop('required', false);
  }
});

$(document).on("click", ".checkbox-child", function() {
	var id;
	id = $(this).attr('data-po-id');
	if (this.checked) {
	  $(".check-input-" + id).prop('required', true);
	} else {
	  $(".check-input-" + id).prop('required', false);
	}
});

$(document).on("click", ".disable_double_click", function(e) {
  //alert ("ok");
  if ( $(this).hasClass("unclickable") ) {
    e.preventDefault();
  } else {
    $(this).addClass("unclickable");
  }
});

$(document).on("click", ".checkbox-dc", function() {
  $(this).siblings('ul')
      .find("input[type='checkbox']")
      .prop('checked', this.checked);
});
//Loads the correct sidebar on window load,
//collapses the sidebar on window resize.
$(function() {
    $(window).bind("load resize", function() {
        width = (this.window.innerWidth > 0) ? this.window.innerWidth : this.screen.width;
        if (width < 768) {
            $('div.sidebar-collapse').addClass('collapse')
        } else {
            $('div.sidebar-collapse').removeClass('collapse')
        }
    })
})
///////////////////////////////////////////// AJAX CALL to get notification updates ////////////////////////////////////////////////////////////
$(document).on("click", ".load-more-notification", function() {
  var page_no = parseFloat($(this).attr('data-page-no'));
  get_notifications(page_no+1);
  $(this).hide();
});

function get_notifications (page){
  // loader = JST["templates/loader"](loader_type = "progressbar");
  $(".notification-loader").show();
  // $(".notification-loader").html(loader);
  // AJAX Request for notification count
  var request = $.ajax({
    url: "/notifications.json",
    method: "GET",
    dataType: "json",
    data: {page: page}
  });
  request.done(function( data, textStatus, jqXHR ) {
    if(data.count > 0) {
      $(".load-notifications").css("animation","blink 1s steps(2, start) infinite")
    }
    build_notification_content(data.notifications.reverse(),data.count,page);
    $(".notification-loader").hide();
  });
  request.fail(function( jqXHR, textStatus ) {
    console.log(textStatus);
    $(".notification-loader").html("Error occured while loading notifications");
  });
}
function build_notification_content (data,count,page) {
  var iventContentStr = ''
  var salesContentStr = ''
  var salesCount = 0
  var iventCount = 0
  for (var i = data.length - 1; i >= 0; i--) {
    if(data[i].notification_type == 'inventory'){
      if(data[i].viewed == false){
        iventCount++
      }
    }
    else{
      if(data[i].viewed == false){
        salesCount++
      }
    }
    if(data[i].priority == 'low') {
      if(data[i].notification_type == 'inventory'){
        if(data[i].viewed == false){
          iventContentStr += '<div class="recent-activity-list border-l-yellow chat-out-list row notification-desc" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }else{
          iventContentStr += '<div class="recent-activity-list border-l-yellow chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }
      }
      else{
        if(data[i].viewed == false){
          salesContentStr += '<div class="recent-activity-list border-l-yellow chat-out-list row notification-desc" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }else{
          salesContentStr += '<div class="recent-activity-list border-l-yellow chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }
      }
    }else if (data[i].priority == 'medium') {
      if(data[i].notification_type == 'inventory'){
        if(data[i].viewed == false){
          iventContentStr += '<div class="recent-activity-list border-l-orange chat-out-list row notification-desc" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }else{
          iventContentStr += '<div class="recent-activity-list border-l-orange chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }
      }
      else{
        if(data[i].viewed == false){
          salesContentStr += '<div class="recent-activity-list border-l-orange chat-out-list row notification-desc" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }else{
          salesContentStr += '<div class="recent-activity-list border-l-orange chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }
      }
    }else if (data[i].priority == 'high') {
      if(data[i].notification_type == 'inventory_stock_expire'){
        if(data[i].viewed == false){
          iventContentStr += '<div class="recent-activity-list border-l-red chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }else if(data[i].notification_type == 'inventory'){
          iventContentStr += '<div class="recent-activity-list border-l-red chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }else if(data[i].notification_type == 'sales'){
          salesContentStr += '<div class="recent-activity-list border-l-red chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
        }
      }else{
        if(data[i].notification_type == 'inventory'){
          if(data[i].viewed == false){
            iventContentStr += '<div class="recent-activity-list border-l-red chat-out-list row notification-desc" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
          }else{
            iventContentStr += '<div class="recent-activity-list border-l-red chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
          }
        }
        else{
          if(data[i].viewed == false){
            salesContentStr += '<div class="recent-activity-list border-l-red chat-out-list row notification-desc" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
          }else{
            salesContentStr += '<div class="recent-activity-list border-l-red chat-out-list row" id="notification-content-'+data[i].id+'" style="line-height: 18px !important;" data-notification-id="'+data[i].id+'">'
          }
        }
      }
    }
    if(data[i].notification_type == 'inventory'){
      iventContentStr += '<div class="col-lg-2 recent-activity-list-icon"><i class="mdi-device-now-widgets"></i></div>'
      iventContentStr += '<div class="col-lg-10 recent-activity-list-text">'
      iventContentStr += '<a class="font-sz-12" href='+data[i].target_url+'>'+data[i].created_at+'<span class="float-r" id="notification-visibility-'+data[i].id+'">'
      if(data[i].viewed == false){
        iventContentStr += '<i class="mdi-action-visibility-off"></i>'
      }else{
        iventContentStr += '<i class="mdi-action-visibility"></i>'
      }
      iventContentStr += '</span></a><p class="font-sz-12">'+data[i].description+'</a>'
      iventContentStr += '</div>'
      iventContentStr += '</div>'
    }else if(data[i].notification_type == 'sales') {
      salesContentStr += '<div class="col-lg-2 recent-activity-list-icon"><i class="mdi-action-shopping-cart"></i></div>'
      salesContentStr += '<div class="col-lg-10 recent-activity-list-text">'
      salesContentStr += '<a class="font-sz-12" href='+data[i].target_url+'>'+data[i].created_at+'<span class="float-r" id="notification-visibility-'+data[i].id+'">'
      if(data[i].viewed == false){
        salesContentStr += '<i class="mdi-action-visibility-off"></i>'
      }else{
        salesContentStr += '<i class="mdi-action-visibility"></i>'
      }
      salesContentStr += '</span></a><p class="font-sz-12">'+data[i].description+'</a>'
      salesContentStr += '</div>'
      salesContentStr += '</div>'
    }
  };
  if(data.length == 0){
    iventContentStr = '<li class="padding-10"><a href="#">Thats all we have for you!</a></li>'
    salesContentStr = '<li class="padding-10"><a href="#">Thats all we have for you!</a></li>'
  }else if(data.length == 20){
    iventContentStr += '<div class="recent-activity-list chat-out-list row load-more-notification" data-page-no="'+page+'"><a href="#" style="line-height: 28px !important;">Load more...</a></div>'
    salesContentStr += '<div class="recent-activity-list chat-out-list row load-more-notification" data-page-no="'+page+'"><a href="#" style="line-height: 28px !important;">Load more...</a></div>'
  }else if(data.length < 20 && data.length >0){
    iventContentStr += '<li class="padding-10"><a href="#">Thats all we have for you!</a></li>'
    salesContentStr += '<li class="padding-10"><a href="#">Thats all we have for you!</a></li>'
  }
  $(".unread-count-sales").html(salesCount);
  $(".unread-count-ivent").html(iventCount);
  $("#recent_activity_inventory").append(iventContentStr);
  $("#recent_activity").append(salesContentStr);
}

$(document).on("mouseenter", ".notification-desc", function() {
  var id = $(this).attr('data-notification-id');
  // AJAX Request
  var request = $.ajax({
    url: "/notifications/"+id+".json",
    method: "PUT",
    dataType: "json",
    data: { viewed: true }
  });
  request.done(function( data, textStatus, jqXHR ) {
    // console.log(data);
    $(".unread-count").html(data.count);
    $("#notification-content-"+id).removeClass('notification-desc');
    $("#notification-visibility-"+id).html('<i class="mdi-action-visibility"></i>');
  });
  request.fail(function( jqXHR, textStatus ) {
    console.log(textStatus);
    // $(".notification-loader").html("Error occured while loading notifications");
  });
});
var dateFormat = function () {
    var    token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
        timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
        timezoneClip = /[^-+\dA-Z]/g,
        pad = function (val, len) {
            val = String(val);
            len = len || 2;
            while (val.length < len) val = "0" + val;
            return val;
        };

    // Regexes and supporting functions are cached through closure
    return function (date, mask, utc) {
        var dF = dateFormat;

        // You can't provide utc if you skip other args (use the "UTC:" mask prefix)
        if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
            mask = date;
            date = undefined;
        }

        // Passing date through Date applies Date.parse, if necessary
        date = date ? new Date(date) : new Date;
        if (isNaN(date)) throw SyntaxError("invalid date");

        mask = String(dF.masks[mask] || mask || dF.masks["default"]);

        // Allow setting the utc argument via the mask
        if (mask.slice(0, 4) == "UTC:") {
            mask = mask.slice(4);
            utc = true;
        }

        var    _ = utc ? "getUTC" : "get",
            d = date[_ + "Date"](),
            D = date[_ + "Day"](),
            m = date[_ + "Month"](),
            y = date[_ + "FullYear"](),
            H = date[_ + "Hours"](),
            M = date[_ + "Minutes"](),
            s = date[_ + "Seconds"](),
            L = date[_ + "Milliseconds"](),
            o = utc ? 0 : date.getTimezoneOffset(),
            flags = {
                d:    d,
                dd:   pad(d),
                ddd:  dF.i18n.dayNames[D],
                dddd: dF.i18n.dayNames[D + 7],
                m:    m + 1,
                mm:   pad(m + 1),
                mmm:  dF.i18n.monthNames[m],
                mmmm: dF.i18n.monthNames[m + 12],
                yy:   String(y).slice(2),
                yyyy: y,
                h:    H % 12 || 12,
                hh:   pad(H % 12 || 12),
                H:    H,
                HH:   pad(H),
                M:    M,
                MM:   pad(M),
                s:    s,
                ss:   pad(s),
                l:    pad(L, 3),
                L:    pad(L > 99 ? Math.round(L / 10) : L),
                t:    H < 12 ? "a"  : "p",
                tt:   H < 12 ? "am" : "pm",
                T:    H < 12 ? "A"  : "P",
                TT:   H < 12 ? "AM" : "PM",
                Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
                o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
                S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
            };

        return mask.replace(token, function ($0) {
            return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
        });
    };
}();

// Some common format strings
dateFormat.masks = {
    "default":      "ddd mmm dd yyyy HH:MM:ss",
    shortDate:      "m/d/yy",
    mediumDate:     "mmm d, yyyy",
    longDate:       "mmmm d, yyyy",
    fullDate:       "dddd, mmmm d, yyyy",
    shortTime:      "h:MM TT",
    mediumTime:     "h:MM:ss TT",
    longTime:       "h:MM:ss TT Z",
    isoDate:        "yyyy-mm-dd",
    isoTime:        "HH:MM:ss",
    isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
    isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
};

// Internationalization strings
dateFormat.i18n = {
    dayNames: [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    ],
    monthNames: [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ]
};

// For convenience...
Date.prototype.format = function (mask, utc) {
    return dateFormat(this, mask, utc);
};

function formatDateTime(date) {
  var datetime = date.split("T");
  var date = datetime[0].split("-")
  var year = date[0]
  var month = date[1]
  var day = date[2]
  var timeWithZone = datetime[1].split("+")
  var timeWithZone = timeWithZone[0].split("-")
  var time = timeWithZone[0]

  var dateString = day+"-"+month+"-"+year+" "+time
  return dateString
}
function convert_amount_to_word(amount){
  var i;
  var i;
  var j;
  var i;
  var atemp, i, j, n_array, n_length, number, received_n_array, words, words_string;
  words = new Array;
  words[0] = '';
  words[1] = 'One';
  words[2] = 'Two';
  words[3] = 'Three';
  words[4] = 'Four';
  words[5] = 'Five';
  words[6] = 'Six';
  words[7] = 'Seven';
  words[8] = 'Eight';
  words[9] = 'Nine';
  words[10] = 'Ten';
  words[11] = 'Eleven';
  words[12] = 'Twelve';
  words[13] = 'Thirteen';
  words[14] = 'Fourteen';
  words[15] = 'Fifteen';
  words[16] = 'Sixteen';
  words[17] = 'Seventeen';
  words[18] = 'Eighteen';
  words[19] = 'Nineteen';
  words[20] = 'Twenty';
  words[30] = 'Thirty';
  words[40] = 'Forty';
  words[50] = 'Fifty';
  words[60] = 'Sixty';
  words[70] = 'Seventy';
  words[80] = 'Eighty';
  words[90] = 'Ninety';
  amount = amount.toString();
  atemp = amount.split('.');
  number = atemp[0].split(',').join('');
  n_length = number.length;
  words_string = '';
  if (n_length <= 11) {
    n_array = new Array(0, 0, 0, 0, 0, 0, 0, 0, 0);
    received_n_array = new Array;
    i = 0;
    while (i < n_length) {
      received_n_array[i] = number.substr(i, 1);
      i++;
    }
    i = 9 - n_length;
    j = 0;
    while (i < 9) {
      n_array[i] = received_n_array[j];
      i++;
      j++;
    }
    i = 0;
    j = 1;
    while (i < 9) {
      if (i == 0 || i == 2 || i == 4 || i == 7) {
        if (n_array[i] == 1) {
          n_array[j] = 10 + parseInt(n_array[j]);
          n_array[i] = 0;
        }
      }
      i++;
      j++;
    }
    value = '';
    i = 0;
    while (i < 9) {
      if (i == 0 || i == 2 || i == 4 || i == 7) {
        value = n_array[i] * 10;
      } else {
        value = n_array[i];
      }
      if (value != 0) {
        words_string += words[value] + ' ';
      }
      if (i == 1 && value != 0 || i == 0 && value != 0 && n_array[i + 1] == 0) {
        words_string += 'Crores ';
      }
      if (i == 3 && value != 0 || i == 2 && value != 0 && n_array[i + 1] == 0) {
        words_string += 'Lakhs ';
      }
      if (i == 5 && value != 0 || i == 4 && value != 0 && n_array[i + 1] == 0) {
        words_string += 'Thousand ';
      }
      if (i == 6 && value != 0 && n_array[i + 1] != 0 && n_array[i + 2] != 0) {
        words_string += 'Hundred and ';
      } else if (i == 6 && value != 0) {
        words_string += 'Hundred ';
      }
      i++;
    }
    words_string = words_string.split('  ').join(' ');
    return words_string;
  }
}
