# organisation & structure

Our biggest challenge had been :

* with deliverability of email to our users (administration)
* ux of email to ours users (students).

Ongoing active measures :

* disable pixel tracking
* setup of SPF
* setup DKIM
* setup DMARC
* setup of DNS sec
* nice sender (avoid no-reply, nice naming)
* send from existing email
* every email are send with well crafted html & text part (better deliverability)
* every email are previewable via /rails/mailers
* ensure subject line between 35/50 chars (https://www.mailjet.com/blog/news/avoid-email-spam-filters/)
