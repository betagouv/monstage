# Circle Ci compatibility

Circle creates the db itself ; avoid .env.development... messes using rails credentials.

credentials.yml.enc includes the same credentials as /.circle-ci/config.yml, change both if needed!

```
create user monstage_test with encrypted password 'monstage_test';
grant all privileges on database monstage_test to monstage_test;
```
