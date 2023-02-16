# organisation & structure

* [app/controllers/api/*](https://github.com/betagouv/monstage/tree/master/app/controllers/api) : related to API. Users::Operator can publish/edit/delete offers directly via our APIs.
* [app/controllers/dashboard/*](https://github.com/betagouv/monstage/tree/master/app/controllers/dashboard) : related to Dashboard. Users::* when connected have a dedicated dashboard.
* [app/controllers/reporting/*](https://github.com/betagouv/monstage/tree/master/app/controllers/reporting) : related to Reporting. Users::PrefectureStatistician when connected have a sum up to operate the platform by department
* [app/controllers/users/*](https://github.com/betagouv/monstage/tree/master/app/controllers/users) : related to devise implementation. We try to keep it as close as possible to devise default
* other controllers are public facing pages (exception for `users_controller.rb` which is the account management, `admin_controller.rb` which is the base clase of rails admin : our administration option)
