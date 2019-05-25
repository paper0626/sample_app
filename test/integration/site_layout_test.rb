require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  
  test "layout links" do
    get root_path
    
    # Homeページが正しいく描画されているか確認
    assert_template 'static_pages/home'
    
    # ?に第二引数のroot_pathなどを当てはめて、
    # <a href="/">...</a>のようなHTMLがあるかどうかをチェックする
    # ルートURLへのリンクは2つあるからcount: 2
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    
    get contact_path
    assert_select "title", full_title("Contact")
    
    get signup_path
    assert_select "title", full_title("Sign up")
  end
end
