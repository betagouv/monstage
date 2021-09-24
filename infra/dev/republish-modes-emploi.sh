#!/bin/bash
set -x

# usage
# 1. download all new documents (usualy a wetransfer sharing)
# 2. move the archive to the root directory of the app
# 3. extract the archive in modes-emplois
# 4. run this file
# 5. commit
convert "modes-emplois/MS3_Guide-d-utilisation-global-2020.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/MS3_Guide-d-utilisation-global-2020.png
convert "modes-emplois/MS3_Mode-d-emploi-eleves.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/MS3_Mode-d-emploi-eleves.png
convert "modes-emplois/MS3_Mode-d-emploi-entreprises.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/MS3_Mode-d-emploi-entreprises.png
convert "modes-emplois/MS3_Mode-d-emploi-membres-pedagogique.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/MS3_Mode-d-emploi-membres-pedagogique.png
convert "modes-emplois/MS3_Mode-d-emploi-referents-departementaux.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/MS3_Mode-d-emploi-referents-departementaux.png

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/MS3_Guide-d-utilisation-global-2020.pdf "modes-emplois/MS3_Guide-d-utilisation-global-2020.pdf"

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/MS3_Mode-d-emploi-eleves.pdf "modes-emplois/MS3_Mode-d-emploi-eleves.pdf"

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/MS3_Mode-d-emploi-entreprises.pdf "modes-emplois/MS3_Mode-d-emploi-entreprises.pdf"

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/MS3_Mode-d-emploi-membres-pedagogique.pdf "modes-emplois/MS3_Mode-d-emploi-membres-pedagogique.pdf"


gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/MS3_Mode-d-emploi-referents-departementaux.pdf "modes-emplois/MS3_Mode-d-emploi-referents-departementaux.pdf"

