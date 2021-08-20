include ApplicationHelper

class GenerateInternshipAgreement < Prawn::Document
  def initialize(internship_agreement_id)
    @internship_agreement = InternshipAgreement.find(internship_agreement_id)
    @pdf = Prawn::Document.new(margin: [40, 40, 100, 40])
  end

  def call
    header
    title
    intro
    parties
    terms
    part_two
    form
    signatures
    footer
    page_number
    @pdf
  end

  def header
    y_position = @pdf.cursor
    @pdf.image "#{Rails.root}/public/assets/logo.png", at: [0, y_position], width: 50
    @pdf.move_down 5
    @pdf.text "Convention n°#{@internship_agreement.id}", :size => 7, :align => :right, :style => :italic
    @pdf.move_down 30
    @pdf.stroke_color '10008F'
    @pdf.stroke_horizontal_rule
  end

  def title
    @pdf.move_down 20
    @pdf.text 'Convention relative à l’organisation de séquence d’observation en milieu professionnel', :size => 20, :align => :center, :color => "10008F"
    @pdf.move_down 20
  end

  def intro
    @pdf.font_size 10
    @pdf.text "Vu le code du travail, et notamment son article L.211-1 ;"
    @pdf.text "Vu le code de l’éducation, et notamment ses articles L.313-1, L.331-4, L.331-5, L.332-3, L. 335-2,"
    @pdf.text "L.411-3, L. 421-7, L. 911-4 ;"
    @pdf.text "Vu le code civil, et notamment son article 1384 ;"
    @pdf.text "Vu le décret n° 2003-812 du 26 août 2003 relatif aux modalités d’accueil en milieu professionnel des élèves mineurs de moins de seize ans ;"
    @pdf.text "Vu la circulaire n° 2003-134 du 8 septembre 2003 relative aux modalités d’accueil en milieu professionnel des élèves mineurs de moins de seize ans ;"
    @pdf.move_down 20
  end
  
  def parties
    subtitle "ENTRE"
    @pdf.text "L’entreprise ou l’organisme d’accueil, #{@internship_agreement.internship_application.internship_offer.employer_name} représentée par #{@internship_agreement.organisation_representative_full_name}, en qualité de chef d’entreprise ou de responsable de l’organisme d’accueil d’une part,"
    @pdf.move_down 10
    subtitle "ET"
    @pdf.text "L’établissement d’enseignement scolaire, #{@internship_agreement.student_school} représenté par #{@internship_agreement.school_representative_full_name}, en qualité de chef d’établissement d’autre part,"
    @pdf.move_down 20
  end
  
  def terms
    subtitle "il a été convenu ce qui suit :"
    subtitle "TITRE PREMIER : DISPOSITIONS GÉNÉRALES"
    html_formating @internship_agreement.terms_rich_text.body.to_s
    @pdf.move_down 20
  end
  
  def part_two
    subtitle "TITRE II - DISPOSITIONS PARTICULIÈRES"
    subtitle "A - Annexe pédagogique"
    @pdf.move_down 10
  end

  def form
    label_form "Nom de l’élève :"
    field_form @internship_agreement.student_full_name 
    label_form "Classe :"
    field_form @internship_agreement.student_class_room 
    label_form "Etablissemenet d'origine :"
    field_form @internship_agreement.student_school 
    label_form "Nom et qualité du responsable de l’accueil en milieu professionnel du tuteur :"
    field_form @internship_agreement.tutor_full_name 
    label_form "Nom du ou des enseignants chargés de suivre le déroulement de séquence d’observation en milieu professionnel : "
    field_form @internship_agreement.main_teacher_full_name 
    label_form "Dates de la séquence d’observation en milieu professionnel :"
    field_form @internship_agreement.date_range 
    label_form "Objectifs assignés à la séquence d’observation en milieu professionnel :"
    field_form @internship_agreement.activity_learnings_rich_text.body.html_safe, html: true
    label_form "Modalités de la concertation qui sera assurée pour organiser la préparation, contrôler le déroulement de la période en vue d’une véritable complémentarité des enseignements reçus :"
    field_form @internship_agreement.activity_preparation_rich_text.body.html_safe, html: true 
    label_form "HORAIRES journaliers de l’élève :"
    field_form @internship_agreement.internship_application.internship_offer.weekly_hours.join('-') 
    label_form "Activités prévues :"
    field_form @internship_agreement.activity_scope_rich_text.body.html_safe, html: true
    label_form "Compétences visées :"
    field_form @internship_agreement.activity_learnings_rich_text.body.html_safe, html: true
    label_form "Modalités d’évaluation de la séquence d’observation en milieu professionnel :"
    field_form @internship_agreement.activity_rating_rich_text.body.html_safe, html: true
    @pdf.move_down 20
  end

  def signatures
    @pdf.text "Fait en 4 exemplaires à #{@internship_agreement.internship_application.student.school.city.capitalize}, le #{(Date.current).strftime('%d/%m/%Y')}."
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
      @pdf.text_box 'Agence Nationale de la Cohésion des Territoires - 20, Avenue de Ségur - 75007 Paris', align: :center, :at => [@pdf.bounds.left, @pdf.bounds.bottom - 35], :height => 20, :width => @pdf.bounds.width, color: 'cccccc'
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
end