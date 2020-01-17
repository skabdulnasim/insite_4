class AccessManagerController < ApplicationController
  load_and_authorize_resource #CanCan
  layout "material"
  
  before_filter :set_module_details
  require 'json'
  def index
    @all_roles = Role.order('created_at asc')
    @new_role = Role.new
  end

  def show
    role = params[:role]
    @role_details = Role.find(role[:id])
    @all_roles = Role.all
    @controllers = AccessManager.where(:controller_status => 1)
    @new_role = Role.new
  end

  def update_role
    @role = Role.find(params[:role][:id])
    
    respond_to do |format|
      if @role.update_attributes(params[:role])
        format.html { redirect_to access_manager_index_path, notice: 'User role has been successfully created.' }
      end      
    end
  end

  def update_capabilities
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
      
      arr_json = JSON.generate(_hash)
      respond_to do |format|
        if Role.where(:id => params[:role_id]).update_all(:capabilities => arr_json)
          format.html { redirect_to access_manager_index_path, notice: 'User role updated.' }
        end      
      end  
    else
      acc_str = " "
      respond_to do |format|
        if Role.where(:id => params[:role_id]).update_all(:capabilities => acc_str)
          format.html { redirect_to access_manager_index_path, notice: 'User role updated.' }
        end      
      end
    end
  end
  
  def create_role
      _role = Role.new(params[:role]) 
      if params[:copy_role_id].present?
        _copy_role = Role.find(params[:copy_role_id])
        _role[:capabilities] = _copy_role.capabilities        
      end
      respond_to do |format|
        if _role.save
          format.html { redirect_to access_manager_index_path, notice: 'User role has been successfully created.' }
        end      
      end
  end
  
  def settings
    @acm = AccessManager.new
    ctrls = AccessManager.where(:controller_status => 1)
    @active_ctrls = Array.new
    ctrls.each do |acl|
      @active_ctrls.push(acl.controller_name)
    end
  end
  
  def show_settings
    cparams = params[:access_manager] 
    @controller = cparams[:controller_name]
    @ctrl_details = AccessManager.where(:controller_name => @controller).first
  end
  def save_settings
    acm = AccessManager.new
    acm[:controller_name] = params[:controller_name]
    acm[:controller_alias] = params[:controller_alias]
    acm[:controller_desc] = params[:controller_desc]
    acm[:controller_status] = params[:controller_status]
    @checked = params[:checked_action]
    if !@checked.nil?
      actions = {}
      @checked.each do |ch|
        arr = {}
        arr[:action_name] = ch
        if params["desc_#{ch}"] == ""
          arr[:action_desc] = "No details found"
        else
          arr[:action_desc] = params["desc_#{ch}"]
        end
        
        actions[ch] = arr
      end 
      actions_json = JSON.generate(actions)
      acm[:controller_actions] = actions_json
      respond_to do |format|
        if acm.save
          format.html { redirect_to access_manager_settings_path, notice: 'Controller successfully updated' }
        else
          format.html { redirect_to access_manager_settings_path, notice: 'Oops! Error occured while updating controller information' }
        end      
      end #End of respond
    else
      respond_to do |format|  
        format.html { redirect_to access_manager_settings_path, notice: 'Oops! Upable to complete operation as no actions has been selected' }
      end    
    end    
  end
  
  def update_settings
    @checked = params[:checked_action]
    if !@checked.nil?
      actions = {}
      @checked.each do |ch|
        arr = {}
        arr[:action_name] = ch
        arr[:action_desc] = params["desc_#{ch}"]
        actions[ch] = arr
      end 
      actions_json = JSON.generate(actions)
      respond_to do |format|
        if AccessManager.where(:controller_name => params[:controller_name]).update_all(:controller_desc => params[:controller_desc],:controller_alias => params[:controller_alias],:controller_status => params[:controller_status],:controller_actions=>actions_json)
          format.html { redirect_to access_manager_settings_path, notice: 'Controller successfully updated' }
        end
      end     
    else
      respond_to do |format|  
        format.html { redirect_to access_manager_settings_path, notice: 'Oops! Upable to complete operation as no actions has been selected' }
      end        
    end    
  end

  private

  def set_module_details
    @module_id = "authorization"
    @module_title = "Authorizations"
  end  
end
