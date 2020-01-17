module SortsHelper
  def update_sort_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :PUT, '/sorts/1.json', "Update SORT"
    error :code => 401, :desc => "Unauthorized"
    param :tab_ip, String, :desc => "Tablet Global IP Address", :required => false
    param :port_no, String, :desc => "Port No", :required => false
    description "Url : http://sumit.lvh.me:3000/sorts/1.json"
    formats ['json', 'jsonp']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def sorts_index_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/sorts.json', "Get sorts"
    param :unit_id, String, :desc => "Unit ID", :required => false
    error :code => 401, :desc => "Unauthorized"
    description "Url : http://sumit.lvh.me:3000/sorts.json?device_id=YOTTO05&unit_id=2" 
    formats ['json', 'html']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#   
  end

  def show_order_detail_status(object)
    if object.status.downcase == "approved"
      content_tag(:span, "#{object.status}", :class => "label", :style => "background-color:#e04a16;")
    elsif  object.status.downcase == "preparing"
      content_tag(:span, "#{object.status}", :class => "label", :style => "background-color:#13eaad;")
    else
      content_tag(:span, "#{object.status}", :class => "label", :style => "background-color:#33eb18;")
    end
  end
end
