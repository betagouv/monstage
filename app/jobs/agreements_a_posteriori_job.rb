class AgreementsAPosterioriJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    return nil if user_id.nil?

    user = User.find_by(id: user_id)
    return nil if user.nil?

    Services::AgreementsAPosteriori.new(employer_id: user.id).perform
  end
end