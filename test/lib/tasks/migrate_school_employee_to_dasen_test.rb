
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
    assert_equal 'education_statistician' , ex_school_employee.role
    assert_equal Users::EducationStatistician.name, ex_school_employee.type
  end

  test 'migrate employer to departmental statistician' do
    school = create(:school, :with_school_manager)
    employer = create(:employer)
    employer_email =  employer.email
    employer_id =  employer.id
    assert_equal 0, Users::PrefectureStatistician.count

    Rake::Task['migrations:from_employer_to_departmental_statistician'].invoke("email:#{employer.email};zipcode:#{'35000'};agreement_signatorable:true]")

    ex_employer = Users::PrefectureStatistician.last
    refute ex_employer.nil?
    assert_equal employer_email, ex_employer.email
    assert_equal Users::PrefectureStatistician.name, ex_employer.type
    assert ex_employer.agreement_signatorable

  end
end