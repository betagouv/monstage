#!/bin/bash
set -x

mkdir -p 'tmp/extracts'
touch 'tmp/extracts/users_extract.csv'
chmod 666 'tmp/extracts/users_extract.csv'
# https://dba.stackexchange.com/questions/158466/relative-path-for-psql-copy-file

psql -d monstage -U etienne <<EOF
\x
COPY (SELECT id, role, email, first_name, last_name from users) TO '/home/etienne/dev/ruby-projects/monstage/tmp/extracts/users_extract.csv' with csv;
EOF

exit $?