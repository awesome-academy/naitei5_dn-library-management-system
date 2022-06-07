class BorrowRequestsController < ApplicationController
  MAX_ALLOWED_BORROW_REQUESTS = Settings.borrow_request.max_allowed.freeze

  before_action :check_logged_in?

  before_action :load_book, :check_quantity_zero, only: :new

  before_action :check_book, :check_quantity_request, :borrowed_book,
                :request_out_of_date, only: :create

  def index
    @pagy, @borrow_reqs = pagy BorrowRequest.by_user(current_user.id)
                                            .ordered_by_status
  end

  def show
    load_borrow_request
  end

  def new
    @borrow_req = @current_user.borrow_requests.new
  end

  def create
    @borrow_req = @current_user.borrow_requests.new borrow_request_params
    if @borrow_req.save
      flash[:success] = t ".request_sent_successfully"
      redirect_to borrow_requests_path
    else
      flash.now[:danger] = t ".request_sent_failed"
      render :new
    end
  end

  def cancel
    load_borrow_request
    if @borrow_req.status_pending?
      @borrow_req.status_cancelled!
      flash[:success] = t ".cancel_success"
    else
      flash[:danger] = t ".cancel_failure"
    end
    redirect_to @borrow_req
  end

  private

  def check_logged_in?
    return if logged_in?

    store_location
    flash[:danger] = t "global.error.need_log_in"
    redirect_to login_url
  end

  def load_borrow_request
    @borrow_req = @current_user.borrow_requests.find_by id: params[:id]
    return if @borrow_req

    store_location
    flash[:danger] = t "global.error.no_permission"
    redirect_to home_path
  end

  def check_quantity_request
    return if @current_user.borrow_requests.active_status
                           .count < MAX_ALLOWED_BORROW_REQUESTS

    flash[:danger] = t ".over_quantity_request"
    redirect_to borrow_requests_path
  end

  def borrowed_book
    return unless @current_user.borrow_requests
                               .pluck(:book_id)
                               .include? params[:borrow_request][:book_id].to_i

    flash[:danger] = t ".borrowed_book"
    redirect_to @book
  end

  def load_book
    @book = Book.find_by id: params.dig(:id)
    return if @book

    flash[:danger] = t ".not_found"
    redirect_to books_path
  end

  def check_book
    @book = Book.find_by id: params.dig(:borrow_request, :book_id)
    return if @book

    flash[:danger] = t ".not_found"
    redirect_to books_path
  end

  def request_out_of_date
    @current_user.borrow_requests.each do |b|
      if b.return_date < Date.current
        flash[:danger] = t ".out_of_date"
        return redirect_to borrow_requests_path
      end
    end
  end

  def borrow_request_params
    params.require(:borrow_request).permit :borrowed_date, :return_date,
                                           :book_id, :status
  end

  def check_quantity_zero
    return unless @book.quantity.zero?

    flash[:danger] = t ".book_out_of_stock"
    redirect_to @book
  end
end
