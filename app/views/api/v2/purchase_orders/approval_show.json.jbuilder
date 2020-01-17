json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_purchase_order_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_purchase_order_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do 
    json.purchase_order do
      json.extract! @purchase_order, :id, :mode, :name, :purchase_order_code, :recurring, :store_id, :unit_id, :user_id, :valid_from, :valid_till, :vendor_id, :business_type, :smart_po_id, :created_at, :updated_at
      json.approvals @purchase_order.approvals do |approval|
        json.extract! approval, :approvable_id, :approvable_type, :is_approve, :reason
        json.role approval.role
        if approval.user.present?
          json.user do
            json.extract! approval.user, :id, :status, :email, :unit_id, :parent_user_id
            json.profile approval.user.profile
          end
        end
      end
      json.purchase_order_metum @purchase_order.purchase_order_metum do |pom|
        json.extract! pom, :product_amount, :product_id, :purchase_order_id, :secondary_amount, :secondary_product_unit_id, :vendor_price, :color_id, :size_id
        json.product pom.product
        json.purchase_order_metum_descrptions pom.purchase_order_metum_descrptions
      end
    end
    json.current_user current_user
    json.current_user_role current_user.role if current_user.present?
  end
end