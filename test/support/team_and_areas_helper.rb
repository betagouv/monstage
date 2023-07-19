module TeamAndAreasHelper
  def create_team(employer_1, employer_2)
    create(:team_member_invitation,
           :accepted_invitation,
           inviter_id: employer_1.id,
           member_id: employer_2.id)
    create(:team_member_invitation,
           :accepted_invitation,
           inviter_id: employer_1.id,
           member_id: employer_1.id)
  end

  def create_internship_offer_visible_by_two(employer_1, employer_2)
    if employer_1.team.not_exists? || !employer_1.team.id_in_team?(employer_2.id)
      create_team(employer_1, employer_2)
    end
    area = employer_1.current_area
    employer_2.current_area = area
    employer_2.save
    create(:weekly_internship_offer,internship_offer_area_id: area.id, employer: employer_1)
  end

  def create_employer_and_offer
    employer = create(:employer)
    offer = create(:weekly_internship_offer,
                   employer: employer,
                   internship_offer_area: employer.current_area)
    [employer, offer]
  end

  def create_user_operator_and_api_offer(operator_id)
    user_operator = create(:user_operator, operator_id: operator_id)
    offer = create(:api_internship_offer,
                    employer: user_operator,
                    internship_offer_area: user_operator.current_area)
    [user_operator, offer]
  end
end