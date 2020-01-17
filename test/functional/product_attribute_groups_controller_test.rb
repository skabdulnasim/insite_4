require 'test_helper'

class ProductAttributeGroupsControllerTest < ActionController::TestCase
  setup do
    @product_attribute_group = product_attribute_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_attribute_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_attribute_group" do
    assert_difference('ProductAttributeGroup.count') do
      post :create, product_attribute_group: { deleted_at: @product_attribute_group.deleted_at, is_system_entity: @product_attribute_group.is_system_entity, name: @product_attribute_group.name, position: @product_attribute_group.position }
    end

    assert_redirected_to product_attribute_group_path(assigns(:product_attribute_group))
  end

  test "should show product_attribute_group" do
    get :show, id: @product_attribute_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_attribute_group
    assert_response :success
  end

  test "should update product_attribute_group" do
    put :update, id: @product_attribute_group, product_attribute_group: { deleted_at: @product_attribute_group.deleted_at, is_system_entity: @product_attribute_group.is_system_entity, name: @product_attribute_group.name, position: @product_attribute_group.position }
    assert_redirected_to product_attribute_group_path(assigns(:product_attribute_group))
  end

  test "should destroy product_attribute_group" do
    assert_difference('ProductAttributeGroup.count', -1) do
      delete :destroy, id: @product_attribute_group
    end

    assert_redirected_to product_attribute_groups_path
  end
end
