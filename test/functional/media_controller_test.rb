require 'test_helper'

class MediaControllerTest < ActionController::TestCase
  setup do
    @medium = media(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create medium" do
    assert_difference('Medium.count') do
      post :create, medium: { asset_id: @medium.asset_id, asset_type: @medium.asset_type, deleted_at: @medium.deleted_at, media_content_type: @medium.media_content_type, media_file_name: @medium.media_file_name, media_file_size: @medium.media_file_size, media_updated_at: @medium.media_updated_at, properties: @medium.properties }
    end

    assert_redirected_to medium_path(assigns(:medium))
  end

  test "should show medium" do
    get :show, id: @medium
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @medium
    assert_response :success
  end

  test "should update medium" do
    put :update, id: @medium, medium: { asset_id: @medium.asset_id, asset_type: @medium.asset_type, deleted_at: @medium.deleted_at, media_content_type: @medium.media_content_type, media_file_name: @medium.media_file_name, media_file_size: @medium.media_file_size, media_updated_at: @medium.media_updated_at, properties: @medium.properties }
    assert_redirected_to medium_path(assigns(:medium))
  end

  test "should destroy medium" do
    assert_difference('Medium.count', -1) do
      delete :destroy, id: @medium
    end

    assert_redirected_to media_path
  end
end
