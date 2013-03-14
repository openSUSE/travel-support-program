# Travel Support Program management application

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

# Requirements

* Ruby 1.9
* Any Rails supported database system: PosgreSQL, MariaDB, MySQL...

# Getting Started

```
$ git clone https://github.com/openSUSE/travel_support_program
$ cd travel_support_program
$ bundle
$ rake db:create db:migrate db:seed
$ rails s
```

# Contact

Ancor González Sosa

* http://github.com/ancorgs
* ancor@suse.de

# License

This application is released under the terms of the GNU Affero General Public
Licence (AGPL). See the LICENSE file for more info
