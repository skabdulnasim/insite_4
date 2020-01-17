class RolesController < ApplicationController

  before_filter :set_permission_groups, only: [:new, :create, :update]
  
  def new
    @role = Role.new
    @permission_groups = PermissionGroup.order('position').includes(:permissions)    
    #@controllers = AccessManager.find(:all, :conditions => ["controller_status =?",1])
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @role }
    end
  end

  def create
    _checked = params[:checked_action]
    if !_checked.nil?
      _hash = Hash.new
      #acc_str = " "
      _checked.each do |ch|
        result = ch.split(/~~/)
        str = "cannot :"+result[0]+", "+result[1]
        controller_name_segments = result[2].split('::')
        controller_name_segments.pop
        controller_namespace = controller_name_segments.join('::').camelize   
        _namespace = controller_namespace.present? ? controller_namespace : "default"
        if _hash.has_key?(_namespace)
          _array = _hash[_namespace]
          _array.push(str)
          _hash[_namespace] = _array
        else
          _arr = ["#{str}"]
          _hash[_namespace] = _arr
        end
      end
      
      @arr_json = JSON.generate(_hash)
      params[:role][:capabilities]=@arr_json
    end

    @role = Role.new(params[:role]) 
    respond_to do |format|
      if @role.save
        format.js
      else
        format.js
      end      
    end
  end

  def update
    _checked = params[:checked_action]
    if !_checked.nil?
      _hash = Hash.new
      #acc_str = " "
      _checked.each do |ch|
        result = ch.split(/~~/)
        str = "cannot :"+result[0]+", "+result[1]
        controller_name_segments = result[2].split('::')
        controller_name_segments.pop
        controller_namespace = controller_name_segments.join('::').camelize   
        _namespace = controller_namespace.present? ? controller_namespace : "default"
        if _hash.has_key?(_namespace)
          _array = _hash[_namespace]
          _array.push(str)
          _hash[_namespace] = _array
        else
          _arr = ["#{str}"]
          _hash[_namespace] = _arr
        end
      end
      
      @arr_json = JSON.generate(_hash)
      params[:role][:capabilities]=@arr_json
    end
    
    @role = Role.find(params[:id])
    respond_to do |format|
      if @role.update_attributes(params[:role])
        format.js
      end
    end
  end

  def edit
    @permission_groups = PermissionGroup.order('position').includes(:permissions)
    @role = Role.find(params[:id])
  end

  def destroy
  end

  def index
  end

  def show
  end

  private

    def set_permission_groups
      @permission_groups = PermissionGroup.order('position').includes(:permissions)    
    end
end
