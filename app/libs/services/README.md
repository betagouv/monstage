# 3rd Parties specifics

## mailjet

### Usage
Jobs synchronize monstage db with mailjet's on every environment. Please take care when considering a full extract of mailjer contacts db of the different environments data come from.
Custom fields are the following :
* monstage_id
* role
* type
* environment (development, test, review, staging, production)
* confirmed_at

