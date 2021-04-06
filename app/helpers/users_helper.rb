# frozen_string_literal: true

module UsersHelper
  def partners_map_of_logo_url
    [
      {
        logo: 'Logo-jobirl.jpg',
        url: 'https://www.jobirl.com',
        height: 50
      },
      {
        logo: 'Logo-le-reseau.jpg',
        url: 'http://www.lereseau.asso.fr',
        height: 50
      },
      {
        logo: 'Logo-moidans10ans.png',
        url: 'https://moidans10ans.fr/',
        height: 50
      },
      {
        logo: 'Logo-les-entreprises-pour-la-cite.jpg',
        url: 'http://www.reseau-lepc.fr',
        height: 50
      },
      {
        logo: 'Logo-tous-en-stage.jpg',
        url: 'https://tousenstage.com',
        height: 50
      },
      {
        logo: 'Logo-un-stage-et-apres.jpg',
        url: 'https://www.unstageetapres.fr',
        height: 50
      },
      {
        logo: 'Logo-viens-voir-mon-taf.jpg',
        url: 'https://www.viensvoirmontaf.fr',
        height: 65
      },
      {
        logo: 'Logo-telemaque.png',
        url: 'https://www.institut-telemaque.org/',
        height: 50
      },

    ].shuffle
  end

  def user_roles_to_select
    Users::SchoolManagement.roles.map do |ruby_role, _pg_role|
      OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
    end
  end
end
