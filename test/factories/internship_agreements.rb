FactoryBot.define do
  factory :internship_agreement do
    internship_application { create(:weekly_internship_application) }
    student_school { internship_application.student.school.name }
    school_representative_full_name { internship_application.student.school.name }
    student_full_name { 'Jean-Claude Dus' }
    student_class_room { '3e A'}
    main_teacher_full_name { 'Paul Lefevbre' }
    organisation_representative_full_name { 'DGSE' }
    tutor_full_name { 'Julie Mentor' }
    date_range { "du 10/10/2020 au 15/10/2020" }
    activity_learnings_rich_text { '<div>Communication orale</div>'}
    activity_scope_rich_text { '<div>Accueil clients</div>'}
    financial_conditions_rich_text { '<div>Ticket resto</div>'}
    activity_preparation_rich_text { '<div>Appel téléphonique</div>'}
    activity_rating_rich_text { '<div>Rapport de stage</div>'}
    school_manager_accept_terms { true }
  end
end
