# frozen_string_literal: true

module UsersHelper


  def main_partners_map_of_logo_url
    {
      "Logo-onisep.jpg" => "https://www.onisep.fr/"
    }.sort.to_h
  end

  def partners_map_of_logo_url
    {
      "Logo-face.jpg" => "https://www.fondationface.org",
      "Logo-degunsanstage.jpg" => "http://www.degunsansstage.fr",
      "Logo-jobirl.jpg" => "https://www.jobirl.com",
      "Logo-le-reseau.jpg" => "http://www.lereseau.asso.fr",
      "Logo-les-entreprises-pour-la-cite.jpg" => "http://www.reseau-lepc.fr",
      "Logo-myfuture.png" => "https://www.myfutu.re",
      "Logo-tous-en-stage.jpg" => "https://tousenstage.com",
      "Logo-un-stage-et-apres.jpg" => "https://www.unstageetapres.fr",
      "Logo-viens-voir-mon-taf.jpg" => "https://www.viensvoirmontaf.fr",
      "Logo-jndj.png" => "https://jndj.org",
      "Logo-united-way.png" => "https://uwafrance.org",
    }.sort.to_h
  end
end
