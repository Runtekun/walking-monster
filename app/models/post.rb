class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true, length: { maximum: 65_535 }

  has_many :comments, dependent: :destroy
  belongs_to :user
  has_one_attached :post_image
end
