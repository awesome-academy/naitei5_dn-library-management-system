class PasswordResetsController < ApplicationController
  include SessionsHelper

  before_action :verify_token, :check_expiration, only: %i(edit update)

  def new; end

  def create
    user_email = params.dig(:password_reset, :email).downcase

    @user = User.activated.find_by email: user_email
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".instruction"
      redirect_to root_url
    else
      flash.now[:danger] = t "users.not_found"
      render :new
    end
  end

  def edit; end

  def update
    if user_params[:password].blank?
      @user.errors.add :password, t(".error")
      render :edit
    elsif @user.update user_params
      @user.clear_password_reset
      login @user
      flash[:success] = t ".success"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def verify_token
    user_email, token = params.values_at :email, :id

    @user = User.activated.find_by email: user_email
    return if @user&.authenticated?(:reset, token)

    flash[:danger] = t ".invalid_link"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".expired"
    redirect_to new_password_reset_url
  end
end
