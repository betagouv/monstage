
require 'test_helper'

class MigrateSchoolEmployeeToDasenTest < ActiveSupport::TestCase

  Monstage::Application.load_tasks

  test 'migrate school employee to dasen' do
    school = create(:school, :with_school_manager)
    school_employee = create(:teacher, school: school)
    assert_equal 0, Users::EducationStatistician.count

    Rake::Task['migrations:from_school_employee_to_edu_stat'].invoke("email:#{school_employee.email};zipcode:#{school.zipcode}]")

    ex_school_employee = Users::EducationStatistician.last
    refute ex_school_employee.nil?
    assert_equal school_employee.email, ex_school_employee.email
    assert_nil ex_school_employee.school_id
    assert_equal 'other' , ex_school_employee.role
    assert_equal Users::EducationStatistician.name, ex_school_employee.type
  end

  test 'migrate employer to departmental statistician' do
    school = create(:school, :with_school_manager)
    employer = create(:employer)
    employer_email =  employer.email
    employer_id =  employer.id
    assert_equal 0, Users::Statistician.count

    Rake::Task['migrations:from_employer_to_departmental_statistician'].invoke("email:#{employer.email};zipcode:#{'35000'};agreement_signatorable:true]")

    whitelist =  EmailWhitelists::Statistician.last
    refute whitelist.nil?
    assert_equal employer_email, whitelist.email
    assert_equal '35' , whitelist.zipcode
    assert_equal employer_id, whitelist.user_id

    ex_employer = Users::Statistician.last
    refute ex_employer.nil?
    assert_equal employer_email, ex_employer.email
    assert_equal Users::Statistician.name, ex_employer.type
    assert ex_employer.agreement_signatorable

  end
end