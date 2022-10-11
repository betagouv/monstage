# frozen_string_literal: true

module UsersHelper
  def partners_map_of_colored_logo_url
    [
      {
        logo: 'logo-moi-dans-10-ans-my-future.png',
        url: 'https://moidans10ans.fr/',
        height: 80
      },
      {
        logo: 'logo-jobirl.png',
        url: 'https://www.jobirl.com',
        height: 80
      },
      {
        logo: 'logo-le-reseau.png',
        url: 'http://www.lereseau.asso.fr',
        height: 80
      },
      {
        logo: 'logo-entreprises-pour-la-cite.png',
        url: 'http://www.reseau-lepc.fr',
        height: 80
      },
      {
        logo: 'logo-tous-en-stage.png',
        url: 'https://tousenstage.com',
        height: 80
      },
      {
        logo: 'logo-un-stage-et-apres.png',
        url: 'https://www.unstageetapres.fr',
        height: 80
      },
      {
        logo: 'logo-viens-voir-mon-taf.png',
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
end
