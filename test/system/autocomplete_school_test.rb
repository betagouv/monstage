# frozen_string_literal: true

require 'application_system_test_case'

class AutocompleteSchoolTest < ApplicationSystemTestCase

  setup do
    @default_school_name = 'Pasteur'
    @default_school_city = 'Mantes-la-Jolie'
    @default_school = create(:school, :with_school_manager, :with_weeks, name: @default_school_name,
                                                            city: @default_school_city)
    @next_school_city = 'Paris'
    @next_school_name = 'Charlemagne'
    @next_school = create(:school, city: @next_school_city,
                                   name: @next_school_name)
  end

  test 'autocomplete school works with default values' do
    school_manager = @default_school.school_manager
    sign_in(school_manager)
    visit account_path(section: :school)
    within(".fr-tabs") do
      click_on 'Mon établissement'
    end

    assert_equal(find_field('Nom (ou ville) de mon établissement').value,
                 @default_school_city,
                 "can't find default school.city")
    assert_equal(find(:css, '#user_school_name').value,
                 @default_school_name,
                 "can't find existing school.name")
    assert_equal(0,
                 all('#user_class_room_id').size,
                 'should not show select class_room')
  end

  test 'autocomplete school allow school_manager to change school' do
    school_manager = @default_school.school_manager
    sign_in(school_manager)
    visit account_path(section: :school)

    assert_changes -> { school_manager.reload.school_id },
                   from: @default_school.id,
                   to: @next_school.id do
      within(".fr-tabs") do
        click_on 'Mon établissement'
      end
      fill_in('Nom (ou ville) de mon établissement', with: @next_school_city[0..3])
      all('.autocomplete-school-results .list-group-item-action').first.click
      assert_equal find_field('Nom (ou ville) de mon établissement').value,
                   @next_school_city,
                   "can't find next school.city"

      select @next_school.name, from: "user_school_id"
      click_on 'Enregistrer'
    end
  end

  test 'reset button works as expected' do
    student = create(:student, school: @default_school)
    sign_in(student)
    visit account_path(section: :school)
    within(".fr-tabs") do
      click_on 'Mon établissement'
    end
    
    if ENV['RUN_BRITTLE_TEST'] && ENV['RUN_BRITTLE_TEST'] == 'true'
      # default presence of fields
      assert_equal 1, all('#user_school_name').size, 'default school name missing'
      assert_equal 1, all('#user_class_room_id').size, 'default class room missing'

      all('.btn-clear-city').first.click
      assert_equal 0, all('#user_school_name').size, 'reset school name fails'
      assert_equal 0, all('#user_class_room_id').size, 'reset class_room fails'
    end
  end

  test 'students changes class_room' do
    default_class_room = create(:class_room, school: @default_school, name: 'mon nom')
    next_class_room = create(:class_room, school: @next_school)

    student = create(:student, school: @default_school, class_room: default_class_room)
    sign_in(student)
    visit account_path(section: :school)
    within(".fr-tabs") do
      click_on 'Mon établissement'
    end

    # default value
    assert_equal(1,
                 all('#user_class_room_name').size,
                 'expected class room input not present')

    fill_in('Nom (ou ville) de mon établissement', with: @next_school_city[0..3])
    all('.autocomplete-school-results .list-group-item-action').first.click
    select @next_school.name, from: "user_school_id"
    select(next_class_room.name, from: 'user_class_room_id')
    click_on 'Enregistrer'

    student.reload
    assert_equal student.school_id, @next_school.id
    assert_equal student.class_room_id, next_class_room.id
  end
end
