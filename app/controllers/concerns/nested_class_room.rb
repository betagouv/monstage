# frozen_string_literal: true

module NestedClassRoom
  extend ActiveSupport::Concern

  included do
    before_action :set_class_room
    before_action :authenticate_user!

    def set_class_room
      @class_room = @school.class_rooms.where(anonymized: false).find(params.require(:class_room_id))
    end
  end
end
