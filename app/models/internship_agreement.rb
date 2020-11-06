# Agreements can be created/modified by two kind of user
# - employer, allowed to manage following fields: TODO
# - school_manager, allowed to manage following fields: TODO
#
# to switch/branch validation, we use an home made mechanism
# which requires either one of those fields:
# - enforce_employer_validation : forcing employer validations
# - enforce_school_manager_validations : forcing school_manager validations
#
# only use dedicated builder to CRUD those objects
class InternshipAgreement < ApplicationRecord
  # include AASM
  belongs_to :internship_application

  validates :student_school,
            :school_representative_full_name,
            :student_full_name,
            :student_class_room,
            :main_teacher_full_name,
            :organisation_representative_full_name,
            :tutor_full_name,
            :start_date,
            :end_date,
            presence: true

  has_rich_text :activity_scope_rich_text
  has_rich_text :activity_preparation_rich_text
  has_rich_text :activity_learnings_rich_text
  has_rich_text :activity_rating_rich_text
  has_rich_text :financial_conditions_rich_text
  has_rich_text :terms_rich_text


  validates_inclusion_of :school_manager_accept_terms,
                         in: ['1', true],
                         message: :school_manager_accept_terms,
                         if: :enforce_school_manager_validations?
  attr_accessor :enforce_school_manager_validations

  validates_inclusion_of :employer_accept_terms,
                         in: ['1', true],
                         message: :employer_accept_terms,
                         if: :enforce_employer_validation?

  attr_accessor :enforce_employer_validations

  validate :at_least_one_validated_terms

  CONVENTION_LEGAL_TERMS = %Q(
    <div>Article 1 - La présente convention a pour objet la mise en œuvre d’une séquence d’observation en milieu professionnel, au bénéfice de l’élève de l’établissement d’enseignement (ou des élèves) désigné(s) en annexe.
    </div>
    <div>Article 2 - Les objectifs et les modalités de la séquence d’observation sont consignés dans l’annexe pédagogique.
    Les modalités de prise en charge des frais afférents à cette séquence ainsi que les modalités d’assurances sont définies dans l’annexe financière.
    </div>
    <div>Article 3 - L’organisation de la séquence d’observation est déterminée d’un commun accord entre le chef d’entreprise ou le responsable de l’organisme d’accueil et le chef d’établissement.
    </div>
    <div>Article 4 - Les élèves demeurent sous statut scolaire durant la période d’observation en milieu professionnel. Ils restent sous l’autorité et la responsabilité du chef d’établissement.
    Ils ne peuvent prétendre à aucune rémunération ou gratification de l’entreprise ou de l’organisme d’accueil.
    </div>
    <div>Article 5 - Durant la séquence d’observation, les élèves n’ont pas à concourir au travail dans l’entreprise ou l’organisme d’accueil.
    Au cours des séquences d’observation, les élèves peuvent effectuer des enquêtes en liaison avec les enseignements. Ils peuvent également participer à des activités de l’entreprise ou de l’organisme d’accueil, à des essais ou à des démonstrations en liaison avec les enseignements et les objectifs de formation de leur classe, sous le contrôle des personnels responsables de leur encadrement en milieu professionnel.
    Les élèves ne peuvent accéder aux machines, appareils ou produits dont l’usage est proscrit aux mineurs par les articles R. 234-11 à R. 234-21 du code du travail. Ils ne peuvent ni procéder à des manœuvres ou manipulations sur d’autres machines, produits ou appareils de production, ni effectuer les travaux légers autorisés aux mineurs par le même code.
    </div>
    <div>Article 6 - Le chef d’entreprise ou le responsable de l’organisme d’accueil prend les dispositions nécessaires pour garantir sa responsabilité civile chaque fois qu’elle sera engagée (en application de l’article 1384 du code civil) :
    - soit en souscrivant une assurance particulière garantissant sa responsabilité civile en cas de faute imputable à l’entreprise ou à l’organisme d’accueil à l’égard de l’élève ;
    - soit en ajoutant à son contrat déjà souscrit « responsabilité civile entreprise » ou « responsabilité civile professionnelle » un avenant relatif à l’accueil d’élèves.
    Le chef de l’établissement d’enseignement contracte une assurance couvrant la responsabilité civile de l’élève pour les dommages qu’il pourrait causer pendant la visite d’information ou séquence d’observation en milieu professionnel, ainsi qu’en dehors de l’entreprise ou de l’organisme d’accueil, ou sur le trajet menant, soit au lieu où se déroule la visite ou séquence, soit au domicile.
    </div>
    <div>Article 7 - En cas d’accident survenant à l’élève, soit en milieu professionnel, soit au cours du trajet, le responsable de l’entreprise s’engage à adresser la déclaration d’accident au chef d’établissement d’enseignement de l’élève dans la journée où l’accident s’est produit.
    </div>
    <div>Article 8 - Le chef d’établissement d’enseignement et le chef d’entreprise ou le responsable de l’organisme d’accueil de l’élève se tiendront mutuellement informés des difficultés qui pourraient naître de l’application de la présente convention et prendront, d’un commun accord et en liaison avec l’équipe pédagogique, les dispositions propres à les résoudre notamment en cas de manquement à la discipline. Les difficultés qui pourraient être rencontrées lors de toute période en milieu professionnel et notamment toute absence d’un élève, seront aussitôt portées à la connaissance du chef d’établissement.
    </div>
    <div>Article 9 - La présente convention est signée pour la durée d’une séquence d’observation en milieu professionnel.
    <div>
  )

  def at_least_one_validated_terms
    return true if [school_manager_accept_terms, employer_accept_terms].any?

    if [enforce_school_manager_validations?, enforce_employer_validation?].none?
      errors.add(:school_manager_accept_terms, :school_manager_accept_terms)
      errors.add(:employer_accept_terms, :employer_accept_terms)
    end
  end

  def enforce_school_manager_validations?
    enforce_school_manager_validations == true
  end

  def enforce_employer_validation?
    enforce_employer_validations == true
  end
end
