# frozen_string_literal: true

module UsersHelper
  def partners_map_logo
    [
      {
        css: 'bg-logo_moi_dans_10_ans_my_future',
        url: 'https://moidans10ans.fr/',
        height: 80
      },
      {
        css: 'bg-logo_jobirl',
        url: 'https://www.jobirl.com',
        height: 80
      },
      {
        css: 'bg-logo_le_reseau',
        url: 'http://www.lereseau.asso.fr',
        height: 80
      },
      {
        css: 'bg-logo_entreprises_pour_la_cite',
        url: 'http://www.reseau-lepc.fr',
        height: 80
      },
      {
        css: 'bg-logo_tous_en_stage',
        url: 'https://tousenstage.com',
        height: 80
      },
      {
        css: 'bg-logo_un_stage_et_apres',
        url: 'https://www.unstageetapres.fr',
        height: 80
      },
      {
        css: 'bg-logo_viens_voir_mon_taf',
        url: 'https://www.viensvoirmontaf.fr',
        height: 80
      }
    ].shuffle
  end

  def user_roles_to_select
    Users::SchoolManagement.roles.map do |ruby_role, _pg_role|
      OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
    end
  end

  def user_roles_without_school_manager_to_select
    roles = { teacher: 'teacher', main_teacher: 'main_teacher', other: 'other' }
    roles.map do |ruby_role, _pg_role|
      OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
    end
  end
end
