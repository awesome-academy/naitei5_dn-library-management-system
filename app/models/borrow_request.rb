class BorrowRequest < ApplicationRecord
  UNACTIVE_STATUS = %w(rejected cancelled).freeze

  validates :borrowed_date, presence: true, allow_blank: false
  validates :return_date, presence: true, allow_blank: false
  validate :check_blank_date?, :invalid_return_date?,
           if: proc{|o| o.errors.empty?}

  belongs_to :user
  belongs_to :book
  has_many :comments, as: :commentable, dependent: :destroy

  delegate :name, to: :user, prefix: true
  delegate :title, to: :book, prefix: true

  enum status: {
    pending: 0,
    ready: 1,
    borrowed: 2,
    returned: 3,
    rejected: 4,
    cancelled: 5
  }, _prefix: true

  scope :by_user, ->(user_id){where(user_id: user_id)}
  scope :by_book, ->(book_id){where(book_id: book_id)}
  scope :ordered_by_status, ->{order :status}
  scope :ordered_by_borrowed_date, ->{order :borrowed_date}
  scope :ordered_by_return_date, ->{order :return_date}
  scope :active_status, ->{where.not status: UNACTIVE_STATUS}

  private
  def check_blank_date?
    return unless [return_date.blank?, borrowed_date.blank?].any?

    errors.add(:return_date, I18n.t("global.error.check_blank_date"))
  end

  def invalid_return_date?
    return if return_date > borrowed_date

    errors.add(:return_date, I18n.t("global.error.invalid_return_date"))
  end
end
