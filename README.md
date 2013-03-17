# Travel Support Program management application

## Disclaimmer

THIS IS A WORK IN PROGRESS AND IS NOT READY YET FOR ANY REAL USAGE...
you have been warned.

## About

This is a Ruby on Rails based application to manage the requests and
reimbursements from travel help programs of free software organizations like the
openSUSE Travel Support Program, the GNOME's Conference Travel Subsidy Program
or the KDE e.V. Travel Cost Reimbursement initiative.

Although been developed initially at the openSUSE Team at SUSE, the goal is to
write a generic application including all the common features so it can be extended
and adapted to fulfill the needs of any organization. This is achieved using
widely used and flexible components as [Bootstrap](http://github.com/twitter/bootstrap)
for the frontend layout or [Devise](https://github.com/plataformatec/devise)
for user authentication.

## Requirements

* Ruby 1.9
* Any Rails supported database system: PosgreSQL, MariaDB, MySQL...

## Getting Started

As most regular Ruby on Rails applications:

```
$ git clone https://github.com/openSUSE/travel_support_program
$ cd travel_support_program
$ vi Gemfile # edit Gemfile to uncomment your favorite database driver
$ bundle
$ cp config/database.sample.yml config/database.yml
$ rake db:create db:migrate db:seed
$ rails s
```

You can access the application pointing your browser to <http://localhost:3000/>
Two initial users should be available with the following emails and passwords:

* tspmember@example.com / tspmember1
* requester@example.com / requester1

## Contact

Ancor González Sosa

* http://github.com/ancorgs
* ancor@suse.de

## License

This application is released under the terms of the GNU Affero General Public
Licence (AGPL). See the {file:LICENSE} file for more info
