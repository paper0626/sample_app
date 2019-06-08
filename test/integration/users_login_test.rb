require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:micheal) # usersはfixtureのusers.ymlを指す。fixtureで設定したmichealを呼び出す
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: {email: @user.email, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user # リダイレクト先が@userのurlかどうか
    follow_redirect! # そのページに実際に移動する
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0 # login_pathのaタグがない
    assert_select "a[href=?]", logout_path # logout_pathのaタグがある
    assert_select "a[href=?]", user_path(@user)
    delete logout_path # DELETEリクエストをログアウト用パスに発行
    assert_not is_logged_in? # loginしていなければOK
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

end