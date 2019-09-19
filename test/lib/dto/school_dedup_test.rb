# frozen_string_literal: true

require 'test_helper'
module Dto
  class SchoolDedupTest < ActiveSupport::TestCase
    setup do
      @code_uai = 'abs'
      @school_rep = create(:school, kind: :rep, code_uai: @code_uai)
    end

    test '.dup? false' do
      duplicate = create(:school, kind: :qpv_proche, code_uai: "lol")
      dedup = SchoolDedup.new(school: duplicate)
      refute dedup.dup?
    end

    test '.dup? true' do
      duplicate = create(:school, kind: :qpv_proche, code_uai: @code_uai)
      dedup = SchoolDedup.new(school: duplicate)
      assert dedup.dup?
    end

    test '.migrate_all destroy qpv proche' do
      duplicate = create(:school, kind: :qpv_proche, code_uai: @code_uai)
      dedup = SchoolDedup.new(school: duplicate)

      assert_changes -> { School.where(id: duplicate.id).count },
                     from: 1,
                     to: 0 do
        dedup.migrate_all
      end
    end

    test '.migrate_all move users to same code_uai but not qpv_proche' do
      duplicate = create(:school, :with_school_manager,
                                          kind: :qpv_proche,
                                          code_uai: @code_uai)

      students = [create(:student, school: duplicate)]
      main_teachers = [create(:main_teacher, school: duplicate)]
      teachers = [create(:teacher, school: duplicate)]
      others = [create(:other, school: duplicate)]

      users = students +
              main_teachers +
              teachers +
              others +
              [duplicate.school_manager]

      dedup = SchoolDedup.new(school: duplicate)
      dedup.migrate_all
      users.map(&:reload).map(&:school_id).map do |user_school_id|
        assert_equal @school_rep.id, user_school_id
      end
    end

     test '.migrate_all move class_rooms' do
      duplicate = create(:school, :with_school_manager,
                               kind: :qpv_proche,
                               code_uai: @code_uai)

      class_room = create(:class_room, school: duplicate)
      dedup = SchoolDedup.new(school: duplicate)

      assert_changes -> { class_room.reload.school_id },
                     from: duplicate.id,
                     to: @school_rep.id do
        dedup.migrate_all
      end
    end

    test '.migrate_all move weeks' do
      duplicate = create(:school, :with_school_manager,
                                  kind: :qpv_proche,
                                  code_uai: @code_uai,
                                  weeks: [Week.first])

      dedup = SchoolDedup.new(school: duplicate)
      assert_changes -> { @school_rep.reload.weeks.count },
                     from: 0,
                     to: 1 do
        dedup.migrate_all
      end
    end
  end
end
