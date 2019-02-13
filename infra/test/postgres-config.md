# Circle Ci compatibility

Circle creates the db itself ; avoid .env.development... messes using rails credentials.

credentials.yml.enc includes the same credentials as /.circle-ci/config.yml, change both if needed!

```
create user tps_test with encrypted password 'tps_test';
grant all privileges on database tps_test to tps_test;
```
