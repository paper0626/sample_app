require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "unsuccessful edit" do
    log_in_as(@user) # ログイン
    get edit_user_path(@user) # 編集ページにアクセス
    assert_template 'users/edit' # editビューが描画されるかチェック
    patch user_path(@user), params: { user: { name: "", # PATCHリクエストを送信
                            email: "foo@invalid",
                            password: "foo",
                            password_confirmation: "bar" } }
    assert_template 'users/edit' # # editビューが表示されるかチェック
  end
  
  test "successful edit" do
    log_in_as(@user) # ログイン
    get edit_user_path(@user) # edit_userページにアクセス
    assert_template 'users/edit' # editビューが描画されるかチェック
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name, # patchリクエストを送信
                            email: email,
                            password: "", # passwordを入力しなくても更新できるようにする
                            password_confirmation: "" } }
    assert_not flash.empty? # flashがemptyじゃなければOK
    assert_redirected_to @user # userの詳細ページにリダイレクトされていたらOK
    @user.reload # データベースから最新のユーザー情報を読み込む
    assert_equal name, @user.name # nameが更新されていたらOK
    assert_equal email, @user.email # emailが更新されていたらOK
  end
  
  test "should redirect edit when not logged in" do
    get edit_user_path(@user) # （ログインせずに）editページに移動
    assert_not flash.empty? # flashがemptyじゃなければOK
    assert_redirected_to login_url # login_urlにリダイレクトされていたらOK
  end
  
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name, # （ログインせずに）patchリクエストを送信
                            email: @user.email } }
    assert_not flash.empty? # falashが空じゃなければOK
    assert_redirected_to login_url # login_urlにリダイレクトされていたらOK
  end
  
  # 違うユーザーのプロフィールを編集しようとしたとき
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  # 違うユーザーのプロフィールをupdateしようとしたとき
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  # フレンドリーフォワーディングのテスト（ユーザーが表示させようとしていたページに遷移する）
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user) # editページへ遷移
    log_in_as(@user) # ログイン
    assert_redirected_to edit_user_url(@user) # editページへ遷移されていたらOK
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name, # patchリクエストを送信
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty? # flashがemptyじゃなければOK
    assert_redirected_to @user # ユーザー詳細ページに遷移されていたらOK
    @user.reload # 最新のユーザー情報をDBから取得
    assert_equal name,  @user.name # nameが更新されていたらOK
    assert_equal email, @user.email # emailが更新さえていたらOK
  end
end
