require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    # 配信されたメッセージ数を初期化
    # 初期化しないと、他で並列して走るテストの影響を受けてしまう
    ActionMailer::Base.deliveries.clear
  end
  
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
  end
  
  test "valid sugnup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                          email: "user@example.com",
                          password: "password",
                          password_confirmation: "password" } }
    end
    # 配信されたメッセージが1つであるか確認
    assert_equal 1, ActionMailer::Base.deliveries.size
    # assignesメソッドを使うと、対応するアクション内のインスタンス変数にアクセスできる
    # Usersコントローラのcreateアクション内の@userにアクセスできる
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

end
