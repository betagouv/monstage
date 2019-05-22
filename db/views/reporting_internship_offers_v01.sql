SELECT
  internship_offers.title,
  internship_offers.zipcode,
  (SELECT substring(zipcode,1,2)) as department_code,
  internship_offers.department as department_name,
  internship_offers.region,
  internship_offers.academy,
  internship_offers.is_public as publicly_code,
  (SELECT sectors.name FROM sectors WHERE id = internship_offers.sector_id) as sector_name,
  (SELECT
      CASE
        WHEN is_public IS TRUE THEN 'Secteur Public'
        ELSE 'Secteur Privé'
        END
  ) as publicly_name,
  internship_offers.group_name,
  internship_offers.blocked_weeks_count,
  internship_offers.total_applications_count,
  internship_offers.convention_signed_applications_count,
  internship_offers.total_male_applications_count,
  internship_offers.total_male_convention_signed_applications_count,
  internship_offers.approved_applications_count,
  internship_offers.created_at
FROM internship_offers
