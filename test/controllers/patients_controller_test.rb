require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get json_index" do
    get :json_index
    assert_response :success
  end

end
