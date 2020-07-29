# frozen_string_literal: true

module UsersHelper
  def partners_map_of_logo_url
    {
      'Logo-face.jpg' => 'https://www.fondationface.org',
      'Logo-degunsanstage.jpg' => 'http://www.degunsansstage.fr',
      'Logo-jobirl.jpg' => 'https://www.jobirl.com',
      'Logo-le-reseau.jpg' => 'http://www.lereseau.asso.fr',
      'Logo-les-entreprises-pour-la-cite.jpg' => 'http://www.reseau-lepc.fr',
      'Logo-myfuture.jpg' => 'https://www.myfutu.re',
      'Logo-tous-en-stage.jpg' => 'https://tousenstage.com',
      'Logo-un-stage-et-apres.jpg' => 'https://www.unstageetapres.fr',
      'Logo-viens-voir-mon-taf.jpg' => 'https://www.viensvoirmontaf.fr',
      'Logo-jndj.jpg' => 'https://jndj.org',
      'Logo-united-way.jpg' => 'https://uwafrance.org'
    }.sort.to_h
  end

  def user_roles_to_select
    Users::SchoolManagement.roles.map do |ruby_role, _pg_role|
      OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
    end
  end
end
