# Travel Support Program management application

[![Build Status](https://travis-ci.org/openSUSE/travel-support-program.svg?branch=master)](https://travis-ci.org/openSUSE/travel-support-program)
[![Coverage Status](https://coveralls.io/repos/openSUSE/travel-support-program/badge.png?branch=master)](https://coveralls.io/r/openSUSE/travel-support-program?branch=master)

## About

This is a Ruby on Rails based application to manage the requests and
reimbursements from travel help programs of free software organizations like the
openSUSE Travel Support Program, the GNOME's Conference Travel Subsidy Program
or the KDE e.V. Travel Cost Reimbursement initiative.

Although been developed initially at the openSUSE Team at SUSE, the goal is to
write a generic application including all the common features so it can be extended
and adapted to fulfill the needs of any organization. This is achieved using
widely used and flexible components like [Bootstrap](http://github.com/twitter/bootstrap)
for the frontend layout or [Devise](https://github.com/plataformatec/devise)
for user authentication.

For a more detailed explanation you can refer to the [ABOUT](doc/ABOUT.md) file, in
which 'the 6 Ws' are developed. That is: who, what, when, where, why and how (yes,
we already know that 'how' does not start with 'W', but we didn't invented the
name).

## Requirements

* Ruby >= 1.9
* Any Rails supported database system: PosgreSQL, SQLite3, MariaDB, MySQL...

## Getting Started

As most regular Ruby on Rails applications:

```
$ git clone https://github.com/openSUSE/travel-support-program
$ cd travel-support-program
$ vi Gemfile # edit Gemfile to uncomment your favorite database driver
$ bundle
$ cp config/database.example.yml config/database.yml
$ cp config/site.example.yml config/site.yml
$ vi config/site.yml # edit configuration DON'T FORGET to set proper secrets
$ rake db:create db:migrate db:seed
$ rails s
```

You can access the application pointing your browser to <http://localhost:3000/>
Four initial users should be available with the following emails and passwords:

* tspmember@example.com / tspmember1
* requester@example.com / requester1
* administrative@example.com / administrative1
* assistant@example.com / assistant1

## Contact

Ancor González Sosa

* http://github.com/ancorgs
* ancor@suse.de

## License

This application is released under the terms of the GNU Affero General Public
Licence (AGPL). See the [LICENSE](LICENSE) file for more info
