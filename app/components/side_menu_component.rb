# frozen_string_literal: true

class SideMenuComponent < ApplicationComponent
  def initialize(candidatures_notice: ,
                 agreements_notice: ,
                 agreements_authorization: ,
                 current_page_offers: false,
                 current_page_candidatures: false,
                 current_page_agreements: false)
    @candidatures_notice = candidatures_notice
    @agreements_notice = agreements_notice
    @agreements_authorization = agreements_authorization
    @current_page_offers = current_page_offers
    @current_page_candidatures = current_page_candidatures
    @current_page_agreements = current_page_agreements
    
  end

  def link_options(menu_item)
    link_options = {class: 'fr-sidemenu__link'}
    link_options.merge!({:'aria-current'=>'page'}) if menu_item[:current_page]
    link_options
  end

  def li_extra_class(menu_item)
    menu_item[:current_page] ? "fr-sidemenu__item--active" : ""
  end

  def before_render
    @menu_collection = [
      {
        label: "Offres de stage",
        path: helpers.dashboard_internship_offers_path,
        notice: nil,
        authorization: true,
        current_page: @current_page_offers
      },
      {
        label: "Candidatures",
        path: helpers.dashboard_candidatures_path,
        notice: @candidatures_notice,
        authorization: true,
        current_page: @current_page_candidatures
      },
      {
        label: "Conventions",
        path: helpers.dashboard_internship_agreements_path,
        notice: @agreements_notice,
        authorization: @agreements_authorization,
        current_page: @current_page_agreements
      }
    ]
  end

end
