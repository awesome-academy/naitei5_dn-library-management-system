class User < ApplicationRecord
  has_many :follow_authors, dependent: :destroy
  has_many :authors, through: :follow_authors, dependent: :destroy
  has_many :borrow_requests, dependent: :nullify
  has_many :borrow_books, through: :borrow_requests, source: :books,
            dependent: :nullify
  has_many :bookmarks, dependent: :destroy
  has_many :bookmark_books, through: :bookmarks, source: :books,
            dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :images, as: :imageable, dependent: :destroy

  enum role: {user: 0, admin: 1}, _prefix: true

  EMAIL_REGEX = Settings.regex.email.freeze

  scope :activated, ->{where activated: true}

  attr_accessor :remember_token, :activation_token, :reset_token

  validates :name, presence: true, length: {maximum: Settings.digits.digit_50}
  validates :email, presence: true,
            length: {maximum: Settings.digits.digit_255},
            format: {with: EMAIL_REGEX}, uniqueness: true
  validates :password, presence: true,
            length: {minimum: Settings.digits.digit_6}, allow_nil: true

  before_create :create_activation_digest
  before_save :downcase_email

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

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(activated: true,
                    activated_at: Time.zone.now,
                    activation_digest: nil)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                    reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.digits.digit_2.hours.ago
  end

  def clear_password_reset
    update_columns(reset_digest: nil, reset_sent_at: nil)
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
