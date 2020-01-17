require 'test_helper'

module DealMaker
  class DealsControllerTest < ActionController::TestCase
    setup do
      @deal = deals(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:deals)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create deal" do
      assert_difference('Deal.count') do
        post :create, deal: { description: @deal.description, end_time: @deal.end_time, name: @deal.name, start_time: @deal.start_time, status: @deal.status }
      end
  
      assert_redirected_to deal_path(assigns(:deal))
    end
  
    test "should show deal" do
      get :show, id: @deal
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @deal
      assert_response :success
    end
  
    test "should update deal" do
      put :update, id: @deal, deal: { description: @deal.description, end_time: @deal.end_time, name: @deal.name, start_time: @deal.start_time, status: @deal.status }
      assert_redirected_to deal_path(assigns(:deal))
    end
  
    test "should destroy deal" do
      assert_difference('Deal.count', -1) do
        delete :destroy, id: @deal
      end
  
      assert_redirected_to deals_path
    end
  end
end
