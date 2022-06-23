# organisation & structure

Our biggest challenge had been :

* with deliverability of email to our users (administration)
* ux of email to ours users (students).

Ongoing active measures :

* disable pixel tracking (gouv recommendation)
* setup of SPF (best practice)
* setup DKIM (best practice)
* setup DMARC (best practice)
* setup of DNS sec (gouv recommendation)
* nice sender (avoid no-reply, nice naming)
* send from existing email (best practice)
* every email are send with well crafted html & text part (best practice)
* every email are previewable via /rails/mailers (for team email review)
* ensure subject line between 35/50 chars
* ensure body does not contains upcase words
* mails a previewable in development,review,staging using `$HOST/rails/mailers`
