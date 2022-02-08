# frozen_string_literal: true

# agreements have some presets,
class InternshipAgreementPreset < ApplicationRecord
  before_create :assign_default

  belongs_to :school
  has_many :internship_agreements, through: :school

  has_rich_text :legal_terms_rich_text
  has_rich_text :complementary_terms_rich_text
  has_rich_text :troisieme_generale_activity_rating_rich_text

  before_save :replicate_school_delegation_to_sign_delivered_at_to_internship_agreements

  LEGAL_TERMS = %Q(
    <div><strong>Article 1</strong> - La présente convention a pour objet la mise en œuvre d’une séquence d’observation en milieu professionnel, au bénéfice de l’élève de l’établissement d’enseignement (ou des élèves) désigné(s) en annexe.
    </div>
    <div><strong>Article 2</strong> - Les objectifs et les modalités de la séquence d’observation sont consignés dans l’annexe pédagogique.
    Les modalités de prise en charge des frais afférents à cette séquence ainsi que les modalités d’assurances sont définies dans l’annexe complémentaire.
    </div>
    <div><strong>Article 3</strong> - L’organisation de la séquence d’observation est déterminée d’un commun accord entre le chef d’entreprise ou le responsable de l’organisme d’accueil et le chef d’établissement.
    </div>
    <div><strong>Article 4</strong> - Les élèves demeurent sous statut scolaire durant la période d’observation en milieu professionnel. Ils restent sous l’autorité et la responsabilité du chef d’établissement.
    Ils ne peuvent prétendre à aucune rémunération ou gratification de l’entreprise ou de l’organisme d’accueil.
    </div>
    <div><strong>Article 5</strong> - Durant la séquence d’observation, les élèves n’ont pas à concourir au travail dans l’entreprise ou l’organisme d’accueil.
    Au cours des séquences d’observation, les élèves peuvent effectuer des enquêtes en liaison avec les enseignements. Ils peuvent également participer à des activités de l’entreprise ou de l’organisme d’accueil, à des essais ou à des démonstrations en liaison avec les enseignements et les objectifs de formation de leur classe, sous le contrôle des personnels responsables de leur encadrement en milieu professionnel.
    Les élèves ne peuvent accéder aux machines, appareils ou produits dont l’usage est proscrit aux mineurs par les articles R. 234-11 à R. 234-21 du code du travail. Ils ne peuvent ni procéder à des manœuvres ou manipulations sur d’autres machines, produits ou appareils de production, ni effectuer les travaux légers autorisés aux mineurs par le même code.
    </div>
    <div><strong>Article 6</strong> - Le chef d’entreprise ou le responsable de l’organisme d’accueil prend les dispositions nécessaires pour garantir sa responsabilité civile chaque fois qu’elle sera engagée (en application de l’article 1384 du code civil) :
    - soit en souscrivant une assurance particulière garantissant sa responsabilité civile en cas de faute imputable à l’entreprise ou à l’organisme d’accueil à l’égard de l’élève ;
    - soit en ajoutant à son contrat déjà souscrit « responsabilité civile entreprise » ou « responsabilité civile professionnelle » un avenant relatif à l’accueil d’élèves.
    Le chef de l’établissement d’enseignement contracte une assurance couvrant la responsabilité civile de l’élève pour les dommages qu’il pourrait causer pendant la visite d’information ou séquence d’observation en milieu professionnel, ainsi qu’en dehors de l’entreprise ou de l’organisme d’accueil, ou sur le trajet menant, soit au lieu où se déroule la visite ou séquence, soit au domicile.
    </div>
    <div><strong>Article 7</strong> - En cas d’accident survenant à l’élève, soit en milieu professionnel, soit au cours du trajet, le responsable de l’entreprise s’engage à adresser la déclaration d’accident au chef d’établissement d’enseignement de l’élève dans la journée où l’accident s’est produit.
    </div>
    <div><strong>Article 8</strong> - Le chef d’établissement d’enseignement et le chef d’entreprise ou le responsable de l’organisme d’accueil de l’élève se tiendront mutuellement informés des difficultés qui pourraient naître de l’application de la présente convention et prendront, d’un commun accord et en liaison avec l’équipe pédagogique, les dispositions propres à les résoudre notamment en cas de manquement à la discipline. Les difficultés qui pourraient être rencontrées lors de toute période en milieu professionnel et notamment toute absence d’un élève, seront aussitôt portées à la connaissance du chef d’établissement.
    </div>
    <div><strong>Article 9</strong> - La présente convention est signée pour la durée d’une séquence d’observation en milieu professionnel.
    <div>
  )

  COMPLEMENTARY_TERMS = %Q(
    <div><strong>1 – HÉBERGEMENT</strong> Ajouter les conditions d'hébergement si besoin.</div>
    <div><br/></div>
    <div><strong>2 – RESTAURATION</strong> Ajouter les conditions de restauration si besoin.</div>
    <div><br/></div>
    <div><strong>3 – TRANSPORT</strong> Ajouter les conditions de transport si besoin.</div>
    <div><br/></div>
    <div><strong>4 – ASSURANCE</strong> Ajouter les conditions d'assurance si besoin.</div>
    <div><br/></div>
    <div><strong>5 – SANITAIRE</strong> Ajouter les conditions sanitaire si besoin.</div>
    <div><br/></div>
    <div><strong>4 – SECURITÉ</strong> Ajouter les conditions liées à la sécurité.</div>
  )

  TROISIEME_GENERALE_ACTIVITY_RATING_RICH_TEXT = %Q(
    <div>Capacité d'écoute, capacité à retenir les informations...</div>
  )

  def filled?
    school_delegation_to_sign_delivered_at.present?
  end

  private
  def replicate_school_delegation_to_sign_delivered_at_to_internship_agreements
    attr_changed = school_delegation_to_sign_delivered_at_changed?
    attr_was_nil = school_delegation_to_sign_delivered_at_was == nil
    if attr_was_nil && attr_changed
      internship_agreements.where(school_delegation_to_sign_delivered_at: nil)
                           .update_all(school_delegation_to_sign_delivered_at: school_delegation_to_sign_delivered_at)
    end
  end

  def assign_default
    legal_terms_rich_text.body = LEGAL_TERMS
    complementary_terms_rich_text.body = COMPLEMENTARY_TERMS
    troisieme_generale_activity_rating_rich_text.body = TROISIEME_GENERALE_ACTIVITY_RATING_RICH_TEXT
  end
end
