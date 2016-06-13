require 'test_helper'

class SupportRequestsControllerTest < ActionController::TestCase
  setup do
    @support_request = support_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:support_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create support_request" do
    assert_difference('SupportRequest.count') do
      post :create, support_request: { expired: @support_request.expired, justification: @support_request.justification, provider: @support_request.provider, shared_key: @support_request.shared_key, ttl: @support_request.ttl, tunnel_created_at: @support_request.tunnel_created_at }
    end

    assert_redirected_to support_request_path(assigns(:support_request))
  end

  test "should show support_request" do
    get :show, id: @support_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @support_request
    assert_response :success
  end

  test "should update support_request" do
    patch :update, id: @support_request, support_request: { expired: @support_request.expired, justification: @support_request.justification, provider: @support_request.provider, shared_key: @support_request.shared_key, ttl: @support_request.ttl, tunnel_created_at: @support_request.tunnel_created_at }
    assert_redirected_to support_request_path(assigns(:support_request))
  end

  test "should destroy support_request" do
    assert_difference('SupportRequest.count', -1) do
      delete :destroy, id: @support_request
    end

    assert_redirected_to support_requests_path
  end
end
