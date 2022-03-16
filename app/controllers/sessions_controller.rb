class SessionsController < ApplicationController
  include SessionsHelper

  def new; end

  def create
    email, password = params[:session].values_at(:email, :password)

    @user = User.find_by email: email.downcase

    return check_activated if @user&.authenticate password

    flash.now[:danger] = t ".create.failed"
    render :new
  end

  def destroy
    log_out if logged_in?
    flash[:info] = t ".destroy"
    redirect_to root_url
  end

  private

  def check_activated
    if @user.activated?
      login @user
      remember_user @user if params[:remember_me] == "1"
      redirect_back_or @user
    else
      flash[:warning] = t ".create.unactivated"
      redirect_to root_url
    end
  end
end
