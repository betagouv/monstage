FROM circleci/postgres:12.0-alpine-postgis

RUN if [ -e $(pg_config --sharedir)/tsearch_data/thesaurus_monstage.ths ]; then \
  wget -O thesaurus_monstage.ths "https://github.com/betagouv/monstage/blob/US/search_internship_offers_per_keywords/db/tsearch_data/thesaurus_monstage.ths" && \
  cp thesaurus_monstage.ths $(pg_config --sharedir)/tsearch_data/thesaurus_monstage.ths \
  ; fi
