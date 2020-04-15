FROM circleci/postgres:12.0-alpine-postgis

RUN wget -O thesaurus_monstage.ths "https://raw.githubusercontent.com/betagouv/monstage/master/db/tsearch_data/thesaurus_monstage.ths"

RUN ls

RUN cp thesaurus_monstage.ths $(pg_config --sharedir)/tsearch_data/thesaurus_monstage.ths

RUN ls $(pg_config --sharedir)/tsearch_data

