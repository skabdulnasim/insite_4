require 'test_helper'

class ProductAttributeSetsControllerTest < ActionController::TestCase
  setup do
    @product_attribute_set = product_attribute_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_attribute_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_attribute_set" do
    assert_difference('ProductAttributeSet.count') do
      post :create, product_attribute_set: { deleted_at: @product_attribute_set.deleted_at, is_default: @product_attribute_set.is_default, name: @product_attribute_set.name }
    end

    assert_redirected_to product_attribute_set_path(assigns(:product_attribute_set))
  end

  test "should show product_attribute_set" do
    get :show, id: @product_attribute_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_attribute_set
    assert_response :success
  end

  test "should update product_attribute_set" do
    put :update, id: @product_attribute_set, product_attribute_set: { deleted_at: @product_attribute_set.deleted_at, is_default: @product_attribute_set.is_default, name: @product_attribute_set.name }
    assert_redirected_to product_attribute_set_path(assigns(:product_attribute_set))
  end

  test "should destroy product_attribute_set" do
    assert_difference('ProductAttributeSet.count', -1) do
      delete :destroy, id: @product_attribute_set
    end

    assert_redirected_to product_attribute_sets_path
  end
end
