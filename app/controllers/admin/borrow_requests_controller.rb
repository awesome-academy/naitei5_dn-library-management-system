class Admin::BorrowRequestsController < Admin::AdminController
  before_action :check_admin_logged_in, only: %i(index show edit)

  def index
    keyword, sort_kw = params.values_at :keyword, :sort_by

    # Check if sort keyword doesn't exists then use default instead
    sort_kw = "created_at" if sort_kw.blank?
    @borrow_reqs = BorrowRequest.ordered_by sort_kw

    # Collect "status"="1" into array of statuses
    # params = {
    #   "status_pending": "0", "status_ready": "1",
    #   "status_borrowed": "0", "status_return": "1",
    #   "status_rejected": "1", "status_cancelled: "0"
    # }
    # => statuses = ["ready", "return", "rejected"]
    statuses = []
    %w(pending ready borrowed returned rejected cancelled).each do |stt|
      status_name = "status_#{stt}"
      statuses << stt if params[status_name] == "1"
    end
    @borrow_reqs = @borrow_reqs.filter_by_status statuses

    # Seach for book title and author name
    @borrow_reqs = @borrow_reqs.search_by keyword

    @pagy, @borrow_reqs = pagy @borrow_reqs
  end

  def show; end

  def edit; end
end
