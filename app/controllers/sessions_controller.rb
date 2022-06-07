class SessionsController < ApplicationController
  include SessionsHelper

  def new; end

  def create
    email, password, remember_me = params[:session].values_at(:email, :password,
                                                              :remember_me)

    user = User.find_by email: email.downcase
    if user&.authenticate password
      login user
      current_user
      remember_user user if remember_me == "1"
      redirect_back_or user
    else
      flash.now[:danger] = t ".create.failed"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    flash[:info] = t ".destroy"
    redirect_to root_url
  end
end
