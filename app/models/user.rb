class User < ApplicationRecord

  has_one :payment
  has_many :images
accepts_nested_attributes_for :payment
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
end
