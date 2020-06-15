# 3rd Parties specifics

## Sendgrid

### Usage
Jobs synchronize monstage db with sendgrid's on every environment. Please take care when considering a full extract of sendgrid contacts db of the different environments data come from.
Custom fields are the following : 
* monstage_id
* role
* type
* environment (development, test, review, staging, production)

Since documentation is wildly missing in the **sendgrid-ruby** gem pages, note the following

### Api documentation 
these two work

```response = sendgrid_client.marketing.contacts.get```

```response = sendgrid_client.marketing.lists.get```

see [this page](https://github.com/sendgrid/sendgrid-ruby/issues/391#issuecomment-583059532) for more details

### Custom fields
Sendgrid's custom fields are not easy ton find : [issue pages](https://github.com/sendgrid/sendgrid-nodejs/issues/953#issuecomment-511227621)
 give details on how to access to Custom fields. Ids are copied from sendgrid traffic analysis and 'hard copied' (from console) to finalize a not to complex solution

#### Sample

```{"0":{"id":"e2_T","name":"role","field_type":"Text","_metadata":{"self":"https://api.sendgrid.com/v3/marketing/field_definitions/e2_T"}}}```

```{"1":{"id":"e3_T","name":"monstage_id","field_type":"Text","_metadata":{"self":"https://api.sendgrid.com/v3/marketing/field_definitions/e3_T"}}}```
