require 'cgi'
include ApplicationHelper

class GenerateInternshipAgreement < Prawn::Document

  def initialize(internship_agreement_id)
    @internship_agreement = InternshipAgreement.find(internship_agreement_id)
    @pdf = Prawn::Document.new(margin: [40, 40, 100, 40])
  end

  PAGE_WIDTH = 532
  SIGNATURE_OPTIONS = {
    position: :center,
    vposition: :center,
    fit: [PAGE_WIDTH / 4, PAGE_WIDTH / 4]
  }

  def call
    header
    title
    current_year
    part_a
    part_b
    part_c
    part_d
    part_e
    part_f

    @pdf.start_new_page
    intro
    article_1
    article_2
    article_3
    article_4
    article_5
    article_6
    article_7
    article_8
    article_9
    article_10
    signatures
    footer
    page_number
    @pdf
  end

  def header
    y_position = @pdf.cursor
    @pdf.image "#{Rails.root}/public/assets/logo.png", at: [0, y_position], width: 50
    @pdf.move_down 5
    @pdf.move_down 30
  end

  def title
    title = "Convention type dématérialisée relative à l’organisation d’une " \
            "séquence d’observation en milieu professionnel des élèves des " \
            "classes de quatrième et de troisième"
    @pdf.move_down 20
    @pdf.text title, :size => 20, :align => :center, :color => "10008F"
    @pdf.move_down 20
  end

  def current_year
    @pdf.font_size 10
    year = SchoolYear::Current.new.beginning_of_period.strftime('%Y').to_i
    years = "Année scolaire : #{year} - #{year + 1}"
    @pdf.table [[years]], {cell_style: {width: PAGE_WIDTH, padding: 5}}
    @pdf.move_down 20
  end

  def part_a
    label_form("Entre")
    @pdf.move_down 10
    label_form("A - Organisme d'accueil : ")
    @pdf.move_down 10


    premises_organisation_name_text = "Nom de l'organisme d'accueil : #{internship_offer.employer_name}"
    @pdf.text premises_organisation_name_text
    # TODO clarify this difference between premises_organisation_name_text & organisation_name_text
    @pdf.move_down 10
    organisation_name_text = "Raison sociale : #{internship_offer.employer_name}"
    @pdf.text organisation_name_text
    @pdf.move_down 2
    @pdf.text "Domaine d'activité : #{internship_offer.sector.name}"
    @pdf.move_down 2
    siret_field = "Numéro d'immatriculation de l'organisme d'accueil (SIRET) : " \
                  "#{@internship_agreement.siret}"
    @pdf.text siret_field
    @pdf.move_down 10
    @pdf.text "Adresse : #{internship_offer.street}, " \
              "#{internship_offer.zipcode} #{internship_offer.city}"
    @pdf.move_down 10
    @pdf.text "Représenté(e) par (nom et prénom) : " \
              "#{@internship_agreement.organisation_representative_full_name} "
    @pdf.move_down 2
    @pdf.text "Fonction : #{@internship_agreement.organisation_representative_role} "
    @pdf.move_down 2
    @pdf.text "Courriel : #{internship_offer.employer.email} "
    @pdf.move_down 2
    @pdf.text "Téléphone : #{internship_offer.employer.phone} "
    @pdf.move_down 10
    @pdf.text "Référent en charge de l’élève au sein de la structure d’accueil" \
              " (nom et prénom) : #{@internship_agreement.tutor_full_name} "
    @pdf.move_down 2
    @pdf.text "Fonction : #{@internship_agreement.tutor_role} "
    @pdf.move_down 2
    @pdf.text "Courriel : #{@internship_agreement.tutor_email} "
    @pdf.move_down 2
    @pdf.text "Téléphone : #{internship_offer.tutor_phone} "
    @pdf.move_down 20
  end

  def part_b
    label_form("B – L’établissement scolaire ci-dessous désigné :")
    @pdf.move_down 10


    @pdf.text "Nom de l'établissement : #{student.school.name} "
    @pdf.move_down 2
    @pdf.text "Adresse : #{student.school.presenter.address} "
    @pdf.move_down 10
    @pdf.text "Représenté par  : #{@internship_agreement.school_representative_full_name} "
    @pdf.move_down 2
    @pdf.text "Fonction  : #{@internship_agreement.school_representative_role} "
    @pdf.move_down 2
    @pdf.text "Courriel  : #{pointing student.school.school_manager.email} "
    @pdf.move_down 2
    @pdf.text "N° de téléphone  : #{pointing student.school.school_manager&.phone} "

    @pdf.move_down 20
  end

  def part_c
    label_form("C – Au bénéfice de l’élève ci-dessous désigné :")
    @pdf.move_down 10


    @pdf.text "Elève concerné : #{student.presenter.formal_name} "
    @pdf.move_down 2
    @pdf.text "Date de naissance : #{student.presenter.birth_date} "
    @pdf.move_down 2
    @pdf.text "Adresse personnelle : #{pointing @internship_agreement.student_address, 75} "
    @pdf.move_down 2
    @pdf.text "Courriel : #{student.email} "
    @pdf.move_down 2
    @pdf.text "N° de téléphone de l’élève : #{pointing student&.phone} "
    @pdf.move_down 2
    @pdf.text "Classe : #{pointing student&.class_room&.name}"
    @pdf.move_down 10
    @pdf.text "Représentant légal (ou personne responsable) n°1 (nom et prénom) :" \
              "#{@internship_agreement.student_legal_representative_full_name} "
    @pdf.move_down 2
    @pdf.text "Courriel : #{@internship_agreement.student_legal_representative_email} "
    @pdf.move_down 2
    @pdf.text "Téléphone : #{@internship_agreement.student_legal_representative_phone} "
    @pdf.move_down 10
    @pdf.text "Le cas échéant, représentant légal n°2 (nom et prénom) : " \
              "#{pointing(@internship_agreement.student_legal_representative_full_name2,  70)} "
    @pdf.move_down 7
    @pdf.text "Courriel : #{pointing(@internship_agreement.student_legal_representative_email2,  70)} "
    @pdf.move_down 7
    @pdf.text "Téléphone : #{pointing(@internship_agreement.student_legal_representative_phone2,  70)} "

    @pdf.move_down 20

  end

  def part_d
    label_form("Aux conditions suivantes : ")
    label_form("D - Dates et lieux")
    @pdf.move_down 5
    from = "Du #{internship_application.week.beginning_of_week_with_year_long}"
    to = "Au #{internship_application.week.end_of_week_with_years_long}"
    @pdf.table([[from, to], [{content: "Soit un nombre de jour de : 5", colspan: 2}]])
    @pdf.move_down 10
    @pdf.text "La séquence d’observation ne peut pas excéder 5 jours consécutifs."
    @pdf.move_down 20
  end

  def part_e
    label_form("E - Finalités pédagogiques")
    @pdf.move_down 20
    @pdf.text "Objectifs assignés à la séquence d'observation : "
    html_formating "<div style='margin-left: 35'>#{@internship_agreement.activity_scope_rich_text}</div>"
    @pdf.move_down 10
    @pdf.text "Activités prévues : "
    html_formating "<div style='margin-left: 35'>#{@internship_agreement.activity_learnings_rich_text}</div>"
    @pdf.move_down 10
    @pdf.text "Modalités de concertation entre le professeur référent " \
              "et le tuteur pour contrôler le déroulement de la période :"
    html_formating "<div style='margin-left: 35'>#{@internship_agreement.activity_rating_rich_text}</div>"
    @pdf.move_down 20
  end

  def part_f
    checkbox_path = "app/front_assets/images/checkbox.png"
    inserted_checkbox = {image: checkbox_path, image_width: 10, image_height: 10}

    label_form("F – Prise en charge financière")
    @pdf.move_down 20
    @pdf.text "Restauration : "
    @pdf.text "L’organisme d’accueil participe-t-il aux frais occasionnés par " \
    "l’élève pendant sa séquence d’observation en milieu professionnel ? "
    @pdf.table([["Oui :", inserted_checkbox, "", ' Non :', inserted_checkbox]]) do |t|
      t.cells.padding = [5, 5, 5, 0]
      t.cells.borders = []
    end
    @pdf.move_down 5
    @pdf.text "Si oui : "
    @pdf.table([["Frais de restauration :#{'.'*40} ",",soit par repas #{'.'*35} " ]]) do |t|
      t.cells.padding = [0, 5, 5, 0]
      t.cells.borders = []
    end
    @pdf.move_down 10
    @pdf.text "Lieu d’hébergement de l’élève s’il n’est pas logé chez ses responsables légaux :"
    @pdf.move_down 30
    @pdf.text "Transport :"

    @pdf.move_down 40
  end



  def intro
    text = "Vu le code du travail, notamment ses articles L. 4153-1 à L. 4153-3" \
           ", L. 4153-5, Vu le code de l’éducation, notamment ses articles. " \
           "D. 331-1 D. 331-3, D. 331-6, D. 331-8, D. 331-9, D. 332 14 et"
    @pdf.text text
    text = "Vu la délibération du conseil d’administration du collège en date du " \
           "#{pointing @internship_agreement.school_delegation_to_sign_delivered_at } " \
           " approuvant la convention-type dématérialisée et autorisant le chef " \
           "d’établissement à conclure au nom de l’établissement toute " \
           "convention relative à la séquence en milieu professionnel conforme " \
           "à la convention-type."
    @pdf.text text
    @pdf.move_down 20
    label_form "Les parties à la présente convention susmentionnées s’engagent" \
               "  au respect des dispositions suivantes :"
    @pdf.move_down 20
  end

  def article_1
    headering("Article 1er – Objet de la convention")
    paraphing("La convention a pour objet la mise en œuvre d’une séquence " \
              "d’observation en milieu professionnel, au bénéfice de l’élève " \
              "ci-dessus désigné (cadre C).")
    paraphing("La séquence d’observation en milieu professionnel s’inscrit dans " \
              "le cadre de l’éducation à l’orientation des élèves. Elle a pour " \
              "objectif de développer les connaissances des élèves sur " \
              "l'environnement technologique, économique et professionnel. ")
    paraphing("La séquence d’observation correspond à une période de mise en " \
              "situation en milieu professionnel au cours duquel l’élève " \
              "découvre différents champs professionnels afin de développer " \
              "ses goûts, ses aptitudes pour définir son projet de formation ultérieur. ")
  end

  def article_2
    headering("Article 2 – Organisation")
    paraphing(
      "L’organisation de la séquence d’observation en milieu professionnel est " \
      "déterminée d’un commun accord " \
      "entre le responsable de l’organisme d’accueil et le chef d’établissement.")

  end

  def article_3
    headering("Article 3 – Modalités pédagogiques et financières")
    paraphing(
      "Les objectifs et les informations pédagogiques sont consignés dans la " \
      "convention (cadre E – Finalités pédagogique).")
    paraphing(
      "Les modalités de prise en charge de la restauration et de l’hébergement" \
      " sont consignées dans la convention (cadre F – Prise en charge financière).")
  end

  def article_4
    headering("Article 4 – Statut de l’élève")
    paraphing(
      "L’élève demeure sous statut scolaire durant sa séquence d’observation" \
      " en milieu professionnel. Il reste sous l’autorité et la responsabilité" \
      " du chef d’établissement.")
    paraphing(
      "L’élève est soumis aux règles générales en vigueur dans l’entreprise, " \
      "notamment en matière de sécurité, de discipline et d’horaires, dans le" \
      " cadre fixé par l’article 8 ci-dessous.")
    paraphing(
      "L’élève est tenu d’observer une entière discrétion sur l’ensemble des" \
      "renseignements qu’il pourra recueillir ou du fait de sa présence dans " \
      "la structure d’accueil. En outre, l’élève s’engage à ne faire figurer " \
      "dans son rapport de stage aucun renseignement confidentiel concernant " \
      "la structure d’accueil."
    )
    paraphing(
      "Il ne peut prétendre à aucune rémunération ou gratification de " \
      "l’entreprise ou de l’organisme d’accueil. ")
  end

  def article_5
    headering("Article 5 – Conditions relatives à la séquence d’observation" \
      " en milieu professionnel")
    paraphing(
      "Durant la séquence d’observation, l’élève n’a pas à concourir au travail" \
      " de l’organisme d’accueil.")
    paraphing(
      "Au cours de cette séquence d’observation, dans le cadre du parcours " \
      "Avenir, l’élève peut effectuer des enquêtes afin de favoriser sa " \
      "découverte de la diversité du monde économique et professionnel et de " \
      "ses multiples voies de formation pour développer sa capacité de " \
      "recherche, d’analyse et d’exploitation de l’information afin de le " \
      "rendre acteur de sa propre orientation. ")
  end

  def article_6
    headering("Article 6 – Sécurité")
    @pdf.text "Le chef de l’organisme d’accueil prend les dispositions " \
              "nécessaires pour garantir sa responsabilité civile chaque fois " \
              "qu’elle sera engagée."
    @pdf.text "Le chef d’établissement contracte une assurance couvrant la " \
              "responsabilité civile de l’élève pour les dommages qu’il " \
              "pourrait causer pendant la durée de sa séquence d’observation " \
              "en milieu professionnel dans la structure où il effectue cette " \
              "séquence."
    @pdf.text "En cas d’accident survenant à l’élève, soit au cours de la " \
              "séquence d’observation, soit au cours du trajet menant au lieu " \
              "où se déroule la séquence d’observation ou au domicile, le chef " \
              "de l’organisme d’accueil s’engage à adresser la déclaration " \
              "d’accident au chef d’établissement de l’élève dans la journée " \
              "où l’accident s’est produit."
  end

  def article_7
    headering("Article 7 – Hébergement et nourriture")
    paraphing(
      "Les modalités de prise en charge de la nourriture sont consignées par" \
      " le chef de l’organisme d’accueil dans la convention (cadre F – " \
      "prise en charge financière). ")
  end

  def article_8
    headering("Article 8 – Durée et horaires de travail des élèves mineurs")
    paraphing(
      "La durée de travail de l’élève mineur ne peut excéder 7 heures par " \
      "jour et 35 heures pour la semaine.")
    paraphing(
      "Au-delà de 4 heures d’activités en milieu professionnel, l’élève doit " \
      "bénéficier d’une pause d’au moins trente minutes.")
    paraphing(
      "Les horaires journaliers de l’élève ne peuvent prévoir leur présence " \
      "sur leur lieu de stage avant huit heures du matin et après dix-huit " \
      "heures le soir. Pour l’élève de moins de seize ans, le travail de nuit " \
      "est interdit. Cette disposition ne souffre aucune dérogation.")

  end

  def article_9
    headering("Article 9 – Coordination entre le chef d’établissement et le " \
      "chef de l’organisme d’accueil, accueillant l’élève en cas de difficultés")
    paraphing(
      "Le chef d’établissement et le chef de l’organisme d’accueil se tiendront" \
      " mutuellement informés des difficultés qui pourraient naître de " \
      "l’application de la présente convention et prendront, d’un commun " \
      "accord et en liaison avec l’équipe pédagogique, les dispositions " \
      "propres à les résoudre. Les difficultés qui pourraient être " \
      "rencontrées, notamment toute absence de l’élève, seront aussitôt portées " \
      "à la connaissance du chef d’établissement. ")
  end

  def article_10
    headering("Article 10 – Durée de validité de la convention")
    paraphing(
      "La convention est signée pour la durée de la séquence d’observation " \
      "au sein de l’organisme d’accueil.")
  end


  # def parties
  #   subtitle "ENTRE"
  #   @pdf.text "L’entreprise ou l’organisme d’accueil, #{internship_offer.employer_name} représentée par #{@internship_agreement.organisation_representative_full_name}, en qualité de chef d’entreprise ou de responsable de l’organisme d’accueil d’une part,"
  #   @pdf.move_down 10
  #   subtitle "ET"
  #   @pdf.text "L’établissement d’enseignement scolaire, #{@internship_agreement.student_school} représenté par #{@internship_agreement.school_representative_full_name}, en qualité de chef d’établissement, a été nommé apte à signer les conventions par le conseil d'administration de l'établissement en date du #{@internship_agreement.school_delegation_to_sign_delivered_at.strftime("%d/%m/%Y")} d’autre part, "
  #   @pdf.move_down 20
  # end

  # def terms
  #   subtitle "il a été convenu ce qui suit :"
  #   subtitle "TITRE PREMIER : DISPOSITIONS GÉNÉRALES"
  #   html_formating @internship_agreement.legal_terms_rich_text.body.to_s
  #   @pdf.move_down 20
  # end

  # def part_two
  #   subtitle "TITRE II - DISPOSITIONS PARTICULIÈRES"
  #   subtitle "A - Convention de preuve"
  #   subtitle "Article 10 -"
  #   field_form "Les Parties conviennent expressément que les documents électroniques échangés sont des écrits électroniques ayant la même valeur probante que des écrits papier."
  #   field_form "Les Parties conviennent expressément que tout document signé de manière dématérialisée depuis la plateforme monstagede3e constitue une preuve littérale au sens du Code civil. Elles reconnaissent que tout document signé de manière dématérialisée vaut preuve du contenu dudit document, de l’identité du signataire et de son consentement aux obligations et conséquences de faits et de droit qui découlent du document signé de manière dématérialisée."
  #   @pdf.move_down 10
  #   subtitle "B - Annexe pédagogique"
  #   @pdf.move_down 10
  # end

  # def form
  #   label_form "Nom de l’élève :"
  #   field_form @internship_agreement.student_full_name

  #   label_form "Classe :"
  #   field_form @internship_agreement.student_class_room

  #   label_form "Etablissemenet d'origine :"
  #   field_form @internship_agreement.student_school

  #   label_form "Nom du responsable de l’accueil en milieu professionnel du tuteur :"
  #   field_form @internship_agreement.tutor_full_name

  #   label_form "Nom du ou des enseignants chargés de suivre le déroulement de séquence d’observation en milieu professionnel : "
  #   field_form @internship_agreement.main_teacher_full_name

  #   label_form "Dates de la séquence d’observation en milieu professionnel :"
  #   field_form @internship_agreement.date_range

  #   label_form "Horaires journaliers de l’élève :"
  #   if @internship_agreement.daily_planning?
  #     %w(lundi mardi mercredi jeudi vendredi samedi).map do |day|
  #       hours = @internship_agreement.new_daily_hours[day]
  #       lunch_break = @internship_agreement.daily_lunch_break[day]
  #       next if hours.blank? || hours.size != 2
  #       daily_schedule = [ "de #{hours[0]} à #{hours[1]}" ]
  #       daily_schedule = daily_schedule.push("pause dejeuner : #{lunch_break}") if lunch_break.present?
  #       field_form "#{day.capitalize} : #{daily_schedule.join(', ')}"
  #     end
  #   else
  #     hours = @internship_agreement.weekly_hours
  #     lunch_break = @internship_agreement.weekly_lunch_break
  #     daily_schedule = [ "de #{hours[0]} à #{hours[1]}" ]
  #     daily_schedule = daily_schedule.push("pause dejeuner : #{lunch_break}") if lunch_break.present?

  #     field_form "Tous les jours : #{daily_schedule.join(', ')}."
  #   end

    unless @internship_agreement.troisieme_generale?
      label_form "Objectifs assignés à la séquence d’observation en milieu professionnel :"
      field_form @internship_agreement.activity_learnings_rich_text.body.html_safe, html: true
    end

    unless @internship_agreement.troisieme_generale?
      label_form "Modalités de la concertation qui sera assurée pour organiser la préparation, contrôler le déroulement de la période en vue d’une véritable complémentarité des enseignements reçus :"
      field_form @internship_agreement.activity_preparation_rich_text.body.html_safe, html: true
    end


    # label_form "Activités prévues :"
    # field_form @internship_agreement.activity_scope_rich_text.body.html_safe, html: true

    unless @internship_agreement.troisieme_generale?
      label_form "Compétences visées :"
      field_form @internship_agreement.activity_learnings_rich_text.body.html_safe, html: true
    end

    # if @internship_agreement.activity_rating_rich_text.present?
    #   label_form "Modalités d’évaluation de la séquence d’observation en milieu professionnel :"
    #   field_form @internship_agreement.activity_rating_rich_text.body.html_safe, html: true
    # end

    # @pdf.move_down 20
  # end

  def pointing(text, len = 35)
    text.nil? ? '.' * len : text
  end


  def signatures
    @pdf.text "Fait à #{internship_application.student.school.city.capitalize}, le .................."
  end

  def page_number
    string = '<page> / <total>'
    options = { :at => [@pdf.bounds.right - 150, -40],
                :width => 150,
                :align => :right,
                :page_filter => (1..7),
                :start_count_at => 1,
                :color => "cccccc" }
    @pdf.number_pages string, options
  end

  def footer
    @pdf.repeat(:all) do
      @pdf.stroke_color '10008F'
      @pdf.stroke do
        @pdf.horizontal_line 0, 540, at: @pdf.bounds.bottom - 25
      end
      @pdf.text_box(internship_application.student.school.presenter.agreement_address,
                    align: :center,
                    :at => [@pdf.bounds.left, @pdf.bounds.bottom - 35],
                    :height => 20,
                    :width => @pdf.bounds.width,
                    color: 'cccccc')
    end
  end

  def subtitle(string)
    @pdf.text string, :color => "10008F", :style => :bold
    @pdf.move_down 10
  end

  def label_form(string)
    @pdf.text string, :style => :bold, size: 10
    @pdf.move_down 5
  end

  def field_form(string, html: false)
    html ? html_formating(string) : @pdf.text(string)
    @pdf.move_down 10
  end

  def html_formating(string)
    @pdf.styled_text string
  end

  def headering(text)
    @pdf.move_down 20
    label_form text
    @pdf.move_down 10
  end

  def paraphing(text)
    @pdf.text text
    @pdf.move_down 10
  end

  def internship_offer
    @internship_agreement.internship_offer
  end

  def internship_application
    @internship_agreement.internship_application
  end

  def student
    internship_application.student
  end

  # def framing(first, *texts)
  #   html = "<div>#{first}</div>"
  #   texts.each do |text|
  #     html = "#{html}<br/><div>#{text}</div>"
  #   end
  #   @pdf.table [[html]], {cell_style: {width: PAGE_WIDTH, padding: 5}}
  # end
end
