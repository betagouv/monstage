class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable
  has_many :internship_offers
  belongs_to :school

  def to_s
    "logged in as : #{type}"
  end
end
