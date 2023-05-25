require 'application_system_test_case'

module Dashboard
  module Students
    class AutocompleteSchoolTest < ApplicationSystemTestCase
      include Devise::Test::IntegrationHelpers

      test 'student can browse his internship_applications' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        internship_applications = {
          drafted: create(:weekly_internship_application, :drafted, student: student),
          submitted: create(:weekly_internship_application, :submitted, student: student),
          approved: create(:weekly_internship_application, :approved, student: student),
          rejected: create(:weekly_internship_application, :rejected, student: student),
          canceled_by_student_confirmation: create(:weekly_internship_application, :canceled_by_student_confirmation, student: student),
          validated_by_employer: create(:weekly_internship_application, :validated_by_employer, student: student),
          canceled_by_student: create(:weekly_internship_application, :canceled_by_student, student: student)
        }
        sign_in(student)
        visit '/'
        click_on 'Candidatures'
        internship_applications.each do |_aasm_state, internship_application|
          badge = internship_application.presenter.student_human_state
          find('.h5.internship-offer-title', text: internship_application.internship_offer.title)
          find("a#show_link_#{internship_application.id}", text: badge[:actions].first[:label]).click
          click_link('toutes mes candidatures')
        end
      end

      test 'student can confirm an employer approval from his applications dashboard' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        internship_application = create(:weekly_internship_application, :validated_by_employer, student: student)
        sign_in(student)
        visit '/'
        click_on 'Candidatures'
        find('.fr-badge.fr-badge--success', text: "ACCEPTÉE PAR L'ENTREPRISE")
        find("#show_link_#{internship_application.id}").click
        assert_equal "validated_by_employer", internship_application.aasm_state
        assert_changes ->{internship_application.reload.aasm_state},
                      from: "validated_by_employer",
                      to: "approved" do
          click_button('Choisir ce stage')
          click_button('Confirmer')
        end
        find '.fr-badge.fr-badge--success', text: "CONFIRMÉE"
        find "a#show_link_#{internship_application.id}", text: "Contacter l'employeur"
      end

      test 'student can submit an application from his applications dashboard' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        internship_application = create(:weekly_internship_application, :drafted, student: student)
        sign_in(student)
        visit '/'
        click_on 'Candidatures'
        find('.fr-badge', text: "BROUILLON")
        find("#show_link_#{internship_application.id}").click
        assert_equal "drafted", internship_application.aasm_state
        assert_changes ->{internship_application.reload.aasm_state},
                      from: "drafted",
                      to: "submitted" do
          find('input[value="Envoyer la demande"]').click
        end
        find '.fr-badge.fr-badge--info', text: "SANS RÉPONSE"
        find "a#show_link_#{internship_application.id}", text: "Renvoyer la demande"
      end

      test 'GET #show as Student with existing draft application shows the draft' do
        if ENV['RUN_BRITTLE_TEST']
          weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
          internship_offer      = create(:weekly_internship_offer, weeks: weeks)
          school                = create(:school, weeks: weeks)
          student               = create(:student, school: school, class_room: create(:class_room, school: school))
          internship_application = create(:weekly_internship_application,
                                          :drafted,
                                          motivation: 'au taquet',
                                          student: student,
                                          internship_offer: internship_offer,
                                          week: weeks.last)

          travel_to(weeks[0].week_date - 1.week) do
            sign_in(student)
            visit internship_offer_path(internship_offer)
            find('.h1', text: internship_offer.title)
            find('.h3', text: internship_offer.employer_name)
            find('.h6', text: internship_offer.street)
            find('.h4', text: 'Informations sur le stage')
            find('.reboot-trix-content', text: internship_offer.description)
            assert page.has_content? 'Stage individuel'
          end
        end
      end

      test 'student can draft, submit, and cancel(by_student) internship_applications' do
        weeks = [Week.find_by(number: 1, year: 2020)]
        school = create(:school, weeks: weeks)
        student = create(:student,
                        school: school,
                        class_room: create( :class_room,
                                            school: school)
                        )
        internship_offer = create(:weekly_internship_offer, weeks: weeks)

        travel_to(weeks.first.week_date) do
          sign_in(student)
          visit internship_offer_path(internship_offer)

          # show application form
          first(:link, 'Postuler').click

          # fill in application form
          human_first_week_label = weeks.first.human_select_text_method
          select human_first_week_label, from: 'internship_application_week_id', wait: 3
          find('#internship_application_motivation', wait: 3).native.send_keys('Je suis au taquet')
          refute page.has_selector?('.nav-link-icon-with-label-success') # green element on screen
          fill_in("Adresse électronique (email)", with: 'parents@gmail.com')
          fill_in("Numéro de téléphone élève ou parent", with: '060011223344')
          assert_changes lambda {
                          student.internship_applications
                                  .where(aasm_state: :drafted)
                                  .count
                        },
                        from: 0,
                        to: 1 do
            click_on 'Valider'
            page.find('#submit_application_form') # timer
          end

          assert_changes lambda {
            student.internship_applications
                  .where(aasm_state: :submitted)
                  .count
                },
                from: 0,
                to: 1 do
            click_on 'Envoyer'
            sleep 0.15
          end

          page.find('h1', text: 'Félicitations !')
        end
      end

      test 'student can update her internship_application' do
        travel_to Date.new(2023,2,1) do
          weeks = Week.selectable_from_now_until_end_of_school_year
          school = create(:school, weeks: weeks)
          student = create(:student,
                          school: school,
                          class_room: create( :class_room,
                                              school: school)
                          )
          internship_offer = create(:weekly_internship_offer, weeks: weeks)
          internship_application = create( :weekly_internship_application,
                                          internship_offer: internship_offer,
                                          student: student)

          sign_in(student)
          visit dashboard_students_internship_applications_path(student_id: student.id)

          click_link 'Voir'

          click_link 'Modifier'
          refute page.has_selector?('.nav-link-icon-with-label-success') # green element on screen

          find('h1.h3', text: 'Ma candidature')

          # fill in application form
          human_first_week_label = weeks.third.human_select_text_method
          select human_first_week_label, from: 'internship_application_week_id', wait: 3
          find('#internship_application_motivation').native.send_keys('et ')
          find('#internship_application_student_attributes_resume_educational_background').native.send_keys("j'ai de l'expérience")
          find('#internship_application_student_attributes_resume_other').native.send_keys("et puis j'ai fait plein de trucs")
          find('#internship_application_student_attributes_resume_languages').native.send_keys("je parle couramment espagnol")
          fill_in("Adresse électronique (email)", with: 'parents@gmail.com')
          fill_in("Numéro de téléphone élève ou parent", with: '060011223344')
          assert_no_changes lambda {
                          student.internship_applications
                                  .where(aasm_state: :drafted)
                                  .count
                        } do
            find('input.fr-btn[type="submit"][name="commit"][value="Valider"]').click
            page.find('#submit_application_form') # timer
          end
          application =  student.internship_applications.last
          assert_equal 'et Suis hyper motivé', application.motivation.body.to_plain_text
          assert_equal "j'ai de l'expérience", application.student.resume_educational_background.body.to_plain_text
          assert_equal "et puis j'ai fait plein de trucs", application.student.resume_other.body.to_plain_text
          assert_equal "je parle couramment espagnol", application.student.resume_languages.body.to_plain_text

          click_link 'Modifier'

          find('h1.h3', text: 'Ma candidature')

          find('input.fr-btn[type="submit"][name="commit"][value="Valider"]').click
        end
      end

      test 'submitted internship_application can be canceled by student' do
        weeks = [Week.find_by(number: 1, year: 2020)]
        school = create(:school, weeks: weeks)
        student = create(:student,
                        school: school,
                        class_room: create(:class_room, school: school)
                        )
        internship_offer = create(:weekly_internship_offer, weeks: weeks)
        internship_application = create( :weekly_internship_application,
                                        :submitted,
                                        internship_offer: internship_offer,
                                        student: student)

        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)

        click_link 'Renvoyer la demande'

        click_button 'Annuler la candidature'

        assert_changes lambda {
          student.internship_applications
                .where(aasm_state: :canceled_by_student)
                .count
              },
              from: 0,
              to: 1 do
          selector = "#internship_application_canceled_by_student_message"
          find(selector).native.send_keys('Je ne suis plus disponible')
          click_button 'Confirmer'
        end
      end

      test 'submitted internship_application can be resent by the student' do
        weeks = [Week.find_by(number: 1, year: 2020)]
        school = create(:school, weeks: weeks)
        student = create(:student,
                         school: school,
                         class_room: create(:class_room, school: school)
                        )
        internship_offer = create(:weekly_internship_offer, weeks: weeks)
        internship_application = create( :weekly_internship_application,
                                        :submitted,
                                        internship_offer: internship_offer,
                                        student: student)

        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)

        click_link 'Renvoyer la demande'

        assert_changes lambda { student.internship_applications.first.reload.dunning_letter_count },
                       from: 0,
                       to: 1 do
          click_button 'Renvoyer la demande'
          find("input[type='submit'][value='Renvoyer la demande']").click
        end

        click_button 'Renvoyer la demande'
        find("input[type='submit'][value='Renvoyer la demande'][disabled='disabled']")
      end

      test "confirmed internship_application can lead student to the employer's contact parameters" do
        weeks = [Week.find_by(number: 1, year: 2020)]
        school = create(:school, weeks: weeks)
        student = create(:student,
                        school: school,
                        class_room: create(:class_room, school: school)
                        )
        internship_offer = create(:weekly_internship_offer, weeks: weeks)
        internship_application = create( :weekly_internship_application,
                                        :approved,
                                        internship_offer: internship_offer,
                                        student: student)

        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)

        click_link "Contacter l'employeur"

        within('.fr-callout') do
          find("h3.fr-callout__title", text: "Contact de l'employeur")
          find('ul li.test-employer-name', text: internship_offer.employer.presenter.formal_name)
          find('ul li.test-employer-email', text: internship_offer.employer.email)
        end
      end
    end
  end
end