require 'test_helper'

class ProductAttributeOptionsControllerTest < ActionController::TestCase
  setup do
    @product_attribute_option = product_attribute_options(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_attribute_options)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_attribute_option" do
    assert_difference('ProductAttributeOption.count') do
      post :create, product_attribute_option: { deleted_at: @product_attribute_option.deleted_at, label: @product_attribute_option.label, position: @product_attribute_option.position, value: @product_attribute_option.value }
    end

    assert_redirected_to product_attribute_option_path(assigns(:product_attribute_option))
  end

  test "should show product_attribute_option" do
    get :show, id: @product_attribute_option
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_attribute_option
    assert_response :success
  end

  test "should update product_attribute_option" do
    put :update, id: @product_attribute_option, product_attribute_option: { deleted_at: @product_attribute_option.deleted_at, label: @product_attribute_option.label, position: @product_attribute_option.position, value: @product_attribute_option.value }
    assert_redirected_to product_attribute_option_path(assigns(:product_attribute_option))
  end

  test "should destroy product_attribute_option" do
    assert_difference('ProductAttributeOption.count', -1) do
      delete :destroy, id: @product_attribute_option
    end

    assert_redirected_to product_attribute_options_path
  end
end
