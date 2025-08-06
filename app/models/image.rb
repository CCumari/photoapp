class Image < ApplicationRecord
  belongs_to :user
  mount_uploader :picture, PictureUploader

  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :picture, presence: true
  validate :picture_size

  private

  def picture_size
    if picture.size > 10.megabytes
      errors.add(:picture, "should be less than 10MB")
    end
  end
end
