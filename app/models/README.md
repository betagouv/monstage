# organisation & structure
We keep our [app/models/*](https://github.com/betagouv/monstage/tree/master/app/models) as close as AR APIs.

By actively avoiding to populate models with utilities methods lots of business logic have been moved to [app/libs/*](https://github.com/betagouv/monstage/tree/master/app/libs) ex:

* data presentation logics in [app/libs/presenters/*](https://github.com/betagouv/monstage/tree/master/app/libs/presenters).
* reporting dimension/metrics in [app/libs/presenters/reporting/*](https://github.com/betagouv/monstage/tree/master/app/libs/presenters/reporting).
* complex query builder in [app/lib/finders/*](https://github.com/betagouv/monstage/tree/master/app/libs/finders).

Also with inspirations from [CQRS](https://martinfowler.com/bliki/CQRS.html), we isolated some business logic into

* [app/models/api/*](https://github.com/betagouv/monstage/tree/master/app/models/api) : related to API domain.
* [app/models/reporting/*](https://github.com/betagouv/monstage/tree/master/app/models/reporting) : related to reporting domain.

User & Roles are based on device + cancancan + STI for each kind of roles, see:

* [app/models/users](https://github.com/betagouv/monstage/tree/master/app/models/users) : all roles on the platform
* [app/models/ability.rb](https://github.com/betagouv/monstage/tree/master/app/models/ability.rb) : sum up ACL per users


# key concepts in our domain

## date (week) matching :
* matching `entities` are `offers/students`. Constraint are :
	* [offer](https://github.com/betagouv/monstage/tree/master/app/models/internship_offer.rb) : an `offer` can be available on 1-n `week`(s)
	* [student](https://github.com/betagouv/monstage/tree/master/app/models/users/student.rb) : a `student` is able to apply to an `offer` depending on its `school` opened `week`(s) (again, 1-n week(s)).
	* date range(s): date ranges may not be contiguous (so we can have to match on non continuons list of week.)

* solution: a reference [weeks](https://github.com/betagouv/monstage/tree/master/app/models/week.rb) table which is a serie of week as "datetime.iso8601(0) format".
	* `internship_offer_weeks` is the join model between `offers` & `weeks`
	* `school_internship_weeks` is the join model bettwen `schools` & available school `weeks`

## geolocation / geo matching :
* context: matching entities are `offers`/`users`. Geo constraints are defined by :
	* an `offer` is geolocable
	* an `user` is geolocable (via his school).
	* geolocation data

* solution (no strong opinion here). We had postgres running, so we postgis which is working great
	* see [nearbyable.rb](https://github.com/betagouv/monstage/tree/master/app/models/concerns/nearbyable.rb)


## fulltext search :
* context: for now searching is limited to `schools.name/city`

* solution : no strong opinion here. We had postgres running, so we use its FTS feature with some updates :

Create a basic french dictionary for the search

```sql
      CREATE TEXT SEARCH DICTIONARY public.french_nostopwords (
        Template = snowball,
        Language = french
      );
```

Remove Stopwords from lexing/stemming on custom dictionnary (so, search like "Par" will find paris instead of ignoring the "Par" french word which is not ignored due to it's stop words nature)

```sql
      ALTER TEXT SEARCH DICTIONARY public.french_nostopwords (
        language = french,
        StopWords
      );
```

Use this dictionnary for french_stem(ing) on public.fr

```sql
      ALTER TEXT SEARCH CONFIGURATION public.fr
        ALTER MAPPING REPLACE french_stem WITH public.french_nostopwords;
```

Then build request indexation with it via [app/models/api/school.rb](https://github.com/betagouv/monstage/tree/master/app/models/api/school.rb)
