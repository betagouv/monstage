#!/bin/bash
set -x

cp ./db/tsearch_data/thesaurus_monstage.ths $(pg_config --sharedir)/tsearch_data/thesaurus_monstage.ths
