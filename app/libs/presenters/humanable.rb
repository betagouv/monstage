  module Presenters::Humanable
    extend ActiveSupport::Concern

    included do
      def formal_name
        "#{user.first_name.try(:capitalize)} #{user.last_name.try(:capitalize)}"
      end
    end
  end