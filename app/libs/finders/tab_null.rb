# frozen_string_literal: true
module Finders
  class TabNull
    def pending_agreements_count
      @application_count ||= 0
    end

    def student_without_class_room_count
      @students_without_classs_room_count ||= 0
    end
  end
end
