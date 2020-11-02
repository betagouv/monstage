# frozen_string_literal: true

module NestedSchool
  extend ActiveSupport::Concern

  included do
    before_action :set_school
    before_action :authenticate_user!

    def set_school
      @school = School.find(params.require(:school_id))
    end
  end
end
