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

## Sending Emails in Travel Support Program

To send emails with travel support program you need to setup some external mail service. For example using the gmail smtp, just add the smtp settings using `config.action_mailer.smtp_settings` in the `environment` files.
For gmail smtp settings you can checkout this <a href="https://support.google.com/a/answer/176600?hl=en">link</a>.

Their are some email variables provided in the site.yml file which your can use to configure emails in TSP :

| Variable          | Content                                       | Purpose                              |
|----------         |---------                                      |---------                             |
| async_emails      | true/false                                    | Enable the usage of delayed_jobs     |
| email_from        | Travel Support Program <noreply@example.com>  | Address used by TSP to send emails   |
| email_footer      | Travel Support Program                        | Footer for email                     |
 
### Testing emails

For testing emails <a href="https://github.com/fgrehm/letter_opener_web">letter opener web gem </a> is provided in TSP. To use it just set the `config.action_mailer.delivery_method` to `:letter_opener` . 

If you are running your app from a Vagrant machine or want to test the emails in production you can set the delivery_method option to `:letter_opener_web`.

After sending an email visit `http://localhost:3000/letter_opener` to view it.
