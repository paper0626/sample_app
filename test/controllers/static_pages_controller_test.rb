require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get root" do
    get root_url
    assert_response :success
  end
  
  test "should get home" do
    # Homeページのテスト。GETリクエストをhomeアクションに対して発行 (=送信) せよ。
    # そうすれば、リクエストに対するレスポンスは[成功]になるはず
    get static_pages_home_url
    assert_response :success
    #titleタグに２つ目の引数の文字列が存在すればOK
    assert_select "title", "Home | Ruby on Rails Tutorial Sample App" 
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end
  
  test "should get about" do
    get static_pages_about_url
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

end
