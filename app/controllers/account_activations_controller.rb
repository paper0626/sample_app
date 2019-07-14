class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # !user.activated?は、すでに有効になっているユーザーを誤って再度有効化しないため
    # 再度有効化が可能だと、攻撃社がユーザーの有効化リンクを踏むだけでログインできてしまう
    # params[:id]にactivation_tokenが入っている
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
