class User < ApplicationRecord
  EMAIL_REGEX = Settings.regex.email.freeze

  before_save :downcase_email

  has_many :follow_authors, dependent: :destroy
  has_many :authors, through: :follow_authors, dependent: :destroy
  has_many :borrow_requests, dependent: :nullify
  has_many :borrow_books, through: :borrow_requests, source: :book,
            dependent: :nullify
  has_many :bookmarks, dependent: :destroy
  has_many :bookmark_books, through: :bookmarks, source: :book,
            dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy

  enum role: {user: 0, admin: 1}, _prefix: true

  attr_accessor :remember_token

  validates :name, presence: true, length: {maximum: Settings.digits.digit_50}
  validates :email, presence: true,
            length: {maximum: Settings.digits.digit_255},
            format: {with: EMAIL_REGEX}, uniqueness: true
  validates :password, presence: true,
            length: {minimum: Settings.digits.digit_6}

  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end

      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticate_token? remember_token
    return false if remember_digest.blank?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  private

  def downcase_email
    email.downcase!
  end
end
