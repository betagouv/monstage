FactoryBot.define do
  factory :internship_agreement do
    internship_application { create(:internship_application) }
    student_school { internship_application.student.school.name }
    school_representative_full_name { internship_application.student.school.name }
    student_full_name { 'Jean-Claude Dus' }
    student_class_room { '3e A'}
    main_teacher_full_name { 'Paul Lefevbre' }
    organisation_representative_full_name { 'DGSE' }
    tutor_full_name { 'Julie Mentor' }
    start_date { 10.days.from_now }
    end_date { 17.days.from_now }
  end
end
