class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable
  has_many :internship_offers

  def targeted_internship_offers
    InternshipOffer.all
  end

  def to_s
    "logged in as : #{type}"
  end

  def after_sign_in_path_for
    raise 'not implemented'
  end
end
