require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
  
  test "index including pagination and delete links" do
    log_in_as(@admin) # ログイン
    get users_path # users/indexにアクセス
    assert_template 'users/index' # users/indexが描画されたらOK
    assert_select 'div.pagination' # divタグのpaginationがあればOK
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      # ユーザー名にusers/showへのリンクがはられていたらOK
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        # deleteが表示されていたらOK
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      # deleteをしてUser.countが-1になっていたらOK
      delete user_path(@non_admin)
    end
  end
  
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
