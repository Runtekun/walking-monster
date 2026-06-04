require "open-uri"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, length: { maximum: 20 }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_one :user_monster, dependent: :destroy
  has_many :user_rankings, dependent: :destroy
  has_one_attached :avatar

  attr_accessor :avatar_url_from_oauth

  after_create :attach_oauth_avatar

  def own?(object)
    id == object&.user_id
  end

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar_url_from_oauth = auth.info.image
    end
  end

  def total_adventure_count
    destinations.where.not(walked_at: nil).count
  end

  private

  def attach_oauth_avatar
    return if avatar_url_from_oauth.blank?
    uri = URI.parse(avatar_url_from_oauth)
    avatar.attach(
      io: uri.open,
      filename: "avatar_#{id}.jpg",
      content_type: "image/jpeg"
    )
  rescue => e
    Rails.logger.warn "OAuth avatar attach failed: #{e.message}"
  end
end
