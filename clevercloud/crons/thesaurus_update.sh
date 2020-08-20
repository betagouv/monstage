#!/bin/bash -l
#see: https://www.clever-cloud.com/doc/tools/crons/

set -x

if [[ "$INSTANCE_NUMBER" != "0" ]]; then
    echo "Instance number is ${INSTANCE_NUMBER}. Stop here."
    exit 0
fi

cd ${APP_HOME}

bundle exec rails internship_offer_keywords:thesaurus_file_generation

source_file=./db/tsearch_data/thesaurus_monstage.ths
if [[ -f $source_file ]]; then
  cp $source_file $(pg_config --sharedir)/tsearch_data/thesaurus_monstage.ths
fi

exit 1