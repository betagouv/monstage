#!/bin/bash
set -x

# usage
# 1. download all new documents (usualy a wetransfer sharing)
# 2. move the archive to the root directory of the app
# 3. extract the archive in /modes-emplois new folder
# 4. run this file
# 5. commit
convert "modes-emplois/MS3_Guide-d-utilisation-global-2020.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/MS3_Guide-d-utilisation-global-2020.png
convert "modes-emplois/Mode_d_emploi_2022-Élèves_et_Parents_d_élèves_VDEF_220818.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/Mode_d_emploi_2022-Élèves_et_Parents_d_élèves_VDEF_220818.png
convert "modes-emplois/Mode_d_emploi_2022-Entreprises_et_Administrations_publiques_VDEF_220818.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/Mode_d_emploi_2022-Entreprises_et_Administrations_publiques_VDEF_220818.png
convert "modes-emplois/Mode_d_emploi_2022-Membres_de_l_équipe_pédagogique_VDEF_220818.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/Mode_d_emploi_2022-Membres_de_l_équipe_pédagogique_VDEF_220818.png
convert "modes-emplois/Mode_d_emploi_2022-Référents_administratifs_et_départementaux_VDEF_220818.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/Mode_d_emploi_2022-Référents_administratifs_et_départementaux_VDEF_220818.png
convert "modes-emplois/Mode-d-emploi-global-2022.pdf[0]" -resize 400x568 ./app/front_assets/images/modes_d_emploi/Mode-d-emploi-global-2022.png

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
   -sOutputFile=public/modes_d_emploi/Mode_d_emploi_2022-Élèves_et_Parents_d_élèves_VDEF_220818.pdf "modes-emplois/Mode_d_emploi_2022-Élèves_et_Parents_d_élèves_VDEF_220818.pdf"

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/Mode_d_emploi_2022-Entreprises_et_Administrations_publiques_VDEF_220818.pdf "modes-emplois/Mode_d_emploi_2022-Entreprises_et_Administrations_publiques_VDEF_220818.pdf"

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/Mode_d_emploi_2022-Membres_de_l_équipe_pédagogique_VDEF_220818.pdf "modes-emplois/Mode_d_emploi_2022-Membres_de_l_équipe_pédagogique_VDEF_220818.pdf"


gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/Mode_d_emploi_2022-Référents_administratifs_et_départementaux_VDEF_220818.pdf "modes-emplois/Mode_d_emploi_2022-Référents_administratifs_et_départementaux_VDEF_220818.pdf"

gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dBATCH \
   -sOutputFile=public/modes_d_emploi/Mode-d-emploi-global-2022.pdf "modes-emplois/Mode-d-emploi-global-2022.pdf"
