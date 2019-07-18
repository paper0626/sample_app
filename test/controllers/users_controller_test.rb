require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should redirect index when logged in" do
    get users_path # users_pathを表示
    assert_redirected_to login_url # login_urlにリダイレクトされていたらOK
  end
  
  test "should get new" do
    get signup_path
    assert_response :success
  end
  
  # ログインしていないユーザーであれば、ログイン画面にリダイレクトされる
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end
  
  # ログイン済みであっても管理者でなければ、ホーム画面にリダイレクトされる
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do # deleteをしてもUser.countが変わらなければOK
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
  
  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
