# frozen_string_literal: true

module FeatureFlipHelper
  def support_listable?(user)
    return true unless user
    return false if user.is_a?(Users::Employer)
    return false if user.is_a?(Users::Operator)

    true
  end
end
