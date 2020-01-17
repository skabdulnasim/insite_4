module RoomsHelper
  def rooms_index_apipie_doc
    api :GET, '/rooms.json', "Get list of all rooms"
    formats ['json', 'jsonp']    
    description "URL : http://dev.selfordering.com/rooms.json?device_id=YOTTO05"
    error :code => 401, :desc => "Unauthorized"
    param :unit_id, 
          String,
          :required => false
  end
end
