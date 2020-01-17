class NotificationsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include NotificationsHelper
  before_filter :get_current_user, only: [:create]

  def index
    unit_id = current_user.present? ? current_user.unit_id : params[:unit_id]
    role_id = current_user.present? ? current_user.role.id : nil
    # @notifications = Notification.set_unit(unit_id).order('created_at DESC')
    @notifications = Notification.set_unit_or_role(unit_id,role_id).order('created_at DESC')
    @filtered_notifications = @notifications.page(params[:page]).per(20) if params[:page].present?

    respond_to do |format|
      format.html #
      format.json{ render json: {:notifications=>@filtered_notifications, :count=>@notifications.is_unread.count} }      
    end    
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def new
    @notification = Notification.new 	
  end

  def create
  	@new_notification = params[:notification]
  	@new_notification[:unit_id] = @current_user.unit_id
  	@new_notification[:notification_type] = "test"
    @notification = Notification.create!(params[:notification])
    #broadcast_notification('/messages/android', @notification) if @notification
  end

  def update
    unit_id = current_user.present? ? current_user.unit_id : params[:unit_id]
    @notification = Notification.find(params[:id])
    @notification.update_attributes(:viewed => params[:viewed]) if params[:viewed].present?
    @notifications = Notification.set_unit(unit_id).is_unread
    respond_to do |format|
      format.json{ render json: {:notification=>@notification, :count=>@notifications.count} }      
    end
  end  

  def stock_expiry_alerts
    @expiry_alerts = stock_expiry_notifications # NotificationsHelper
    @expiry_alerts.each { |expiry_alert| expiry_alert.update_column(:viewed,true) } if @expiry_alerts.present?
  end

  def thresh_hold_alerts
    @stores= params[:thresh_hold_store].present? ? Store.set_id_in(params[:thresh_hold_store]) : Store.set_unit_in(current_user.unit_id)
    @products = Product.thresh_hold_product
    @products = @products.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    smart_listing_create :thresh_hold_alert, @products, partial: "notifications/thresh_hold_alert_samrtlisting"
  end
  def approval_alerts
    _current_user_role = current_user.role
    @approvals = _current_user_role.approvals #.order("id desc")
    @approvals = @approvals.filter_by_is_approve(params[:is_approve]) if params[:is_approve].present?
    @approvals = @approvals.filter_by_approvable_type(params[:approvable_type]) if params[:approvable_type].present?
    smart_listing_create :approval_alert, @approvals, partial: "notifications/approval_alert_samrtlisting"
  end
end
