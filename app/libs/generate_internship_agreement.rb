require 'cgi'
require 'open-uri'
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
    article_bonus
    signatures
    (0..2).each do |slice|
      signature_table_header(slice: slice)
      signature_table_body(slice: slice)
      signature_table_signature(slice: slice)
      signature_table_footer
      @pdf.move_down 20
    end

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
    @pdf.text enc "Représenté(e) par (nom et prénom) : " \
              "#{@internship_agreement.organisation_representative_full_name} "
    @pdf.move_down 2
    @pdf.text "Fonction : #{enc @internship_agreement.organisation_representative_role} "
    @pdf.move_down 2
    @pdf.text "Courriel : #{internship_offer.employer.email} "
    @pdf.move_down 2
    @pdf.text "Téléphone : #{internship_offer.employer.phone} "
    @pdf.move_down 10
    @pdf.text "Référent en charge de l’élève au sein de la structure d’accueil" \
              " (nom et prénom) : #{@internship_agreement.tutor_full_name} "
    @pdf.move_down 2
    @pdf.text "Fonction : #{enc @internship_agreement.tutor_role} "
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
    @pdf.text enc "Représenté par  : #{@internship_agreement.school_representative_full_name} "
    @pdf.move_down 2
    @pdf.text enc "Fonction  : #{@internship_agreement.school_representative_role} "
    @pdf.move_down 2
    @pdf.text "Courriel  : #{dotting student.school.school_manager.email} "
    @pdf.move_down 2
    @pdf.text "N° de téléphone  : #{dotting @internship_agreement.school_representative_phone} "

    @pdf.move_down 20
  end

  def part_c
    label_form("C – Au bénéfice de l’élève ci-dessous désigné :")
    @pdf.move_down 10


    @pdf.text "Elève concerné : #{student.presenter.formal_name} "
    @pdf.move_down 2
    @pdf.text "Date de naissance : #{student.presenter.birth_date} "
    @pdf.move_down 2
    @pdf.text enc "Adresse personnelle : #{dotting(@internship_agreement.student_address, 75)}"
    @pdf.move_down 2
    @pdf.text "Courriel : #{student.email} "
    @pdf.move_down 2
    @pdf.text "N° de téléphone de l’élève : #{dotting student&.phone} "
    @pdf.move_down 2
    @pdf.text "Classe : #{dotting student&.class_room&.name}"
    @pdf.move_down 10
    @pdf.text "Représentant légal (ou personne responsable) n°1 (nom et prénom) :" \
              "#{@internship_agreement.student_legal_representative_full_name} "
    @pdf.move_down 2
    @pdf.text "Courriel : #{@internship_agreement.student_legal_representative_email} "
    @pdf.move_down 2
    @pdf.text "Téléphone : #{@internship_agreement.student_legal_representative_phone} "
    @pdf.move_down 10
    @pdf.text "Le cas échéant, représentant légal n°2 (nom et prénom) : " \
              "#{dotting(@internship_agreement.student_legal_representative_2_full_name,  70)} "
    @pdf.move_down 7
    @pdf.text "Courriel : #{dotting(@internship_agreement.student_legal_representative_2_email,  70)} "
    @pdf.move_down 7
    @pdf.text "Téléphone : #{dotting(@internship_agreement.student_legal_representative_2_phone,  70)} "

    @pdf.move_down 20

  end

  def part_d
    label_form("Aux conditions suivantes : ")
    label_form("D - Dates et lieux")
    @pdf.move_down 5
    from = "Du #{internship_application.week.beginning_of_week_with_year_long}"
    to = "Au #{internship_application.week.friday_of_week_with_years_long}"
    @pdf.table([[from, to], [{content: "Soit un nombre de jours de : 5", colspan: 2}]])
    @pdf.move_down 10
    @pdf.text "Les horaires de présence de l’élève sont fixés à : "
    @pdf.move_down 10
    %w(lundi mardi mercredi jeudi vendredi).each_with_index do |weekday, i|
      if @internship_agreement.daily_planning?
        start_hours = @internship_agreement.daily_hours&.dig(weekday)&.first
        end_hours = @internship_agreement.daily_hours&.dig(weekday)&.last
      else
        start_hours = @internship_agreement.weekly_hours&.first
        end_hours = @internship_agreement.weekly_hours&.last
      end
      @pdf.text "#{weekday.capitalize} de #{start_hours.gsub(':', 'h')} à #{end_hours.gsub(':', 'h')}"
      @pdf.move_down 5
    end
    @pdf.move_down 10
    @pdf.text "Repas :"
    @pdf.move_down 10
    @pdf.text @internship_agreement.lunch_break
    @pdf.move_down 20

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
           "#{dotting @internship_agreement.school_delegation_to_sign_delivered_at } " \
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
    paraphing(
      "Concernant les modalités d'accueil en milieu professionnel d'élèves mineurs " \
      "de moins de quatorze ans, il convient de se référer à l’annexe 4, de la " \
      "circulaire n° 2003-134 du 8 septembre 2003. La durée de présence " \
      "d’un élève mineur en milieu professionnel ne peut excéder 7 heures par jour. " \
      "Les horaires journaliers des élèves ne peuvent prévoir leur présence sur " \
      "leur lieu de stage avant six heures du matin et après vingt heures le soir."
    )
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

  def article_bonus
    return unless @internship_agreement.student.school.agreement_conditions_rich_text.present?
    headering("Article 11")
    html_formating "<div style=''>#{@internship_agreement.student.school.agreement_conditions_rich_text.body.html_safe}</div>"
    @pdf.move_down 30
  end
  
  def signatures
    @pdf.text "Fait en trois exemplaires à #{@internship_agreement.school_manager.school.city.capitalize}, le #{(Date.current).strftime('%d/%m/%Y')}."

    @pdf.move_down 20
  end

  def signature_data
    { header: [[
        "Le chef d'établissement",
        "Le responsable de l'organisme d'accueil",
        "L'élève",
        "Les parents       (responsables légaux)",
        "Le professeur référent",
        "Le référent en charge de l’élève à sein de l’organisme d’accueil"
        ]],
      body: [
        [""]*6,
        [
          "Nom et prénom : #{school_manager.presenter.formal_name}",
          "Nom et prénom : #{employer.presenter.formal_name}",
          "Nom et prénom : #{student.presenter.formal_name}",
          "Nom et prénom : #{dotting(@internship_agreement.student_legal_representative_full_name)}",
          "Nom et prénom : #{dotting(@internship_agreement.student_refering_teacher_full_name)}",
          "Nom et prénom : #{"." *58}"
        ],
        [
          signature_date_str(signatory_role:'school_manager'),
          signature_date_str(signatory_role:'employer'),
          "Signé le : #{"." * 70}",
          "Signé le : #{"." * 70}",
          "Signé le : #{"." * 70}",
          "Signé le : #{"." * 70}"
        ]],
      signature_part: [
        [image_from(signature: download_image_and_signature(signatory_role: 'school_manager')),
         image_from(signature: download_image_and_signature(signatory_role: 'employer')),
         "",
         "",
         "",
         ""]]
    }
  end

  def signature_table_header(slice:)
    table_data = slice_by_two(signature_data[:header], slice: slice)
    @pdf.table(
      table_data,
      row_colors: ["F0F0F0"],
      column_widths: [PAGE_WIDTH / 2] * 2,
      cell_style: {size: 10}
    ) do |t|
        t.cells.border_color="cccccc"
        t.cells.align=:center
    end
  end

  def signature_table_body(slice:)
    table_data = slice_by_two(signature_data[:body], slice: slice)

    @pdf.table(
      table_data,
      row_colors: ["FFFFFF"],
      column_widths: [PAGE_WIDTH / 2] * 2
    )  do |t|
      t.cells.borders = [:left, :right]
      t.cells.border_color="cccccc"
      t.cells.height= 20
    end
  end

  def signature_table_signature(slice:)
    table_data = slice_by_two(signature_data[:signature_part], slice: slice)
    @pdf.table(
      table_data,
      row_colors: ["FFFFFF"],
      column_widths: [PAGE_WIDTH / 2] * 2
    )  do |t|
      t.cells.borders = [:left, :right]
      t.cells.border_color="cccccc"
      t.cells.height= 100
    end
  end

  def signature_table_footer
    @pdf.table(
      [[""] * 2],
      row_colors: ["FFFFFF"],
      column_widths: [PAGE_WIDTH / 2] * 2,
      cell_style: {size: 8, color: '555555'}
    )  do |t|
      t.cells.borders = [:left, :right, :bottom]
      t.cells.border_color="cccccc"
    end
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

  def dotting(text, len = 35)
    text.nil? ? '.' * len : text
  end



  private



  def image_from(signature: )
    signature.nil? ? "" : {image: signature.local_signature_image_file_path}.merge(SIGNATURE_OPTIONS)
  end

  def download_image_and_signature(signatory_role:)
    signature = @internship_agreement.signature_by_role(signatory_role: signatory_role)
    return nil if signature.nil?
    # When local images stay in the configurated storage directory
    return signature if Rails.application.config.active_storage.service == :local

    # When on external storage service , they are to be donwloaded
    img = signature.signature_image.download if signature.signature_image.attached?
    return nil if img.nil?

    File.open(signature.local_signature_image_file_path, "wb") { |f| f.write(img) }
    signature
  end

  def signature_date_str(signatory_role:)
    if @internship_agreement.signature_image_attached?(signatory_role: signatory_role)
      return @internship_agreement.signature_by_role(signatory_role: signatory_role).presenter.signed_at
    end

    ''
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

  def employer
    internship_application.internship_offer.employer
  end

  def school_manager
    internship_application.student.school_manager
  end

  def student
    internship_application.student
  end

  def referent_teacher
    internship_agreement.referent_teacher
  end

  def slice_by_two(array, slice:)
    table_data = []
    array.each do |row|
      table_data << row.each_slice(2).to_a[slice]
    end
    table_data
  end

  def enc(str)
    str ? str.encode("Windows-1252","UTF-8", undef: :replace, invalid: :replace) : ''
  end
end
