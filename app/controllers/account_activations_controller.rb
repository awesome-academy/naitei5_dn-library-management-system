class AccountActivationsController < ApplicationController
  include SessionsHelper

  def edit
    user_email, token = params.values_at :email, :id
    user = User.find_by email: user_email

    if user&.authenticated?(:activation, token) && !user.activated?
      user.activate
      login user
      flash[:success] = t ".success"
      redirect_to user
    else
      flash[:danger] = t ".failed"
      redirect_to root_url
    end
  end
end
