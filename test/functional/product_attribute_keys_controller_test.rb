require 'test_helper'

class ProductAttributeKeysControllerTest < ActionController::TestCase
  setup do
    @product_attribute_key = product_attribute_keys(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_attribute_keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_attribute_key" do
    assert_difference('ProductAttributeKey.count') do
      post :create, product_attribute_key: { attribute_code: @product_attribute_key.attribute_code, default_value: @product_attribute_key.default_value, deleted_at: @product_attribute_key.deleted_at, input_type: @product_attribute_key.input_type, is_comparable: @product_attribute_key.is_comparable, is_required: @product_attribute_key.is_required, is_sortable: @product_attribute_key.is_sortable, is_system_entity: @product_attribute_key.is_system_entity, is_unique: @product_attribute_key.is_unique, label: @product_attribute_key.label, position: @product_attribute_key.position }
    end

    assert_redirected_to product_attribute_key_path(assigns(:product_attribute_key))
  end

  test "should show product_attribute_key" do
    get :show, id: @product_attribute_key
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_attribute_key
    assert_response :success
  end

  test "should update product_attribute_key" do
    put :update, id: @product_attribute_key, product_attribute_key: { attribute_code: @product_attribute_key.attribute_code, default_value: @product_attribute_key.default_value, deleted_at: @product_attribute_key.deleted_at, input_type: @product_attribute_key.input_type, is_comparable: @product_attribute_key.is_comparable, is_required: @product_attribute_key.is_required, is_sortable: @product_attribute_key.is_sortable, is_system_entity: @product_attribute_key.is_system_entity, is_unique: @product_attribute_key.is_unique, label: @product_attribute_key.label, position: @product_attribute_key.position }
    assert_redirected_to product_attribute_key_path(assigns(:product_attribute_key))
  end

  test "should destroy product_attribute_key" do
    assert_difference('ProductAttributeKey.count', -1) do
      delete :destroy, id: @product_attribute_key
    end

    assert_redirected_to product_attribute_keys_path
  end
end
