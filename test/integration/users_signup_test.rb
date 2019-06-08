require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  # ユーザー登録に失敗したときに正常に動作しているかどうかのテスト
  test "invalid signup information" do
    get signup_path # ユーザー登録ページにアクセス
    # assert_no_differnceのブロックを実行する前後で、User.countが変わらないことをテスト
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: "", 
                                          email: "user@invalid",
                                          password: "foo", 
                                          password_confirmation: "bar" }}
    end
    assert_template 'users/new' # newアクションが再描画されるはず
    assert_select 'div#error_explanation' # HTMLに<div id="error_explanation"></div>が含まれているかどうか
    assert_select 'div.field_with_errors' # HTMLに<div class="field_with_errors"></div>が含まれているかどうか
    assert_select 'form[action="/signup"]' 
  end
  
  # ユーザー登録に成功したときのテスト
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count' do
      post signup_path, params: { user: { name: "Example User", 
                                          email: "user@example.com",
                                          password: "password", 
                                          password_confirmation: "password" }}
    end
    follow_redirect! # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    assert_template 'users/show' # リダイレクト先のshowアクションが正しく表示されればOK
    assert_not flash.empty? # flashの中身が空じゃなかったらOK
    assert is_logged_in? # ログインしていたらOK
  end
end
