# frozen_string_literal: true

module FeatureFlipHelper
  def support_listable?(user)
    return true unless user
    return false if user.employer?
    return false if user.operator?

    true
  end
end
