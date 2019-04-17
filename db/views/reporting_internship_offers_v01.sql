SELECT
  internship_offers.title,
  (SELECT sectors.name FROM sectors WHERE id = internship_offers.sector_id) as sector_name,
  internship_offers.employer_zipcode,
  (SELECT substring(employer_zipcode,1,2)) as employer_departement,
  internship_offers.is_public,
  (SELECT
      CASE
        WHEN is_public IS TRUE THEN 'Secteur Public'
        ELSE 'Secteur Privé'
        END
  ) as publicy,
  internship_offers.blocked_weeks_count,
  internship_offers.total_applications_count,
  internship_offers.convention_signed_applications_count,
  internship_offers.approved_applications_count
FROM internship_offers
