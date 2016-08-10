require 'test_helper'
class TwitterControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should return response" do
    post result_url, params: { username: 'tusharmaroo' }
    assert_response :success
  end
end
