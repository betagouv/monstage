class User < ApplicationRecord
  has_many :internship_offers

  def to_s
    "logged in as : #{type}"
  end
end
