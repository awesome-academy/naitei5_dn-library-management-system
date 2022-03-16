module SessionsHelper
  def login user
    session[:user_id] = user.id
  end

  def remember_user user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = {
      value: user.remember_token,
      httponly: true
    }
  end

  def current_user
    user_id ||= session[:user_id] || cookies.signed[:user_id]
    token = cookies[:remember_token]

    @current_user ||= User.find_by id: user_id
    login @current_user if @current_user&.authenticated?(:remember, token)

    @current_user
  end

  def current_user? user_id
    user_id && user_id.to_i == current_user.try(:id)
  end

  def can_delete? user_id
    current_user.admin? && !current_user?(user_id)
  end

  def logged_in?
    current_user.present?
  end

  def forget user
    user&.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete :forwarding_url
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
