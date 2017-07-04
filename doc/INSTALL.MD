# Install Travel Support Program Application

All the Information you need to Install TSP. If you face any issues with installing don't hesitate to <a href="https://github.com/openSUSE/travel-support-program#contact">contact us</a>.

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
