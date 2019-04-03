class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

 validates :first_name, :last_name,
           presence: true

  def targeted_internship_offers
    InternshipOffer.kept
  end

  def to_s
    "logged in as : #{type}[##{id}]"
  end

  def name
    "#{first_name} #{last_name}"
  end

  def after_sign_in_path
    nil # I know you don't like it Martin but in this cas it makes sense
  end
end
