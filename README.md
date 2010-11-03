# Lettr
Deliver your Emails inside your application through the lettr.de API.

## Installation

    $ gem install lettr

If you want to use lettr inside a Rails 2.x application just drop the following line into you config/environment.rb

    config.gem 'lettr'

For Rails 3.x or if you use Bundler drop the following line into your Gemfile:

    gem 'lettr'

NOTE: In a Rails 3 Application you currently cant use Delivery Method nor Lettr::Mailer.

## Configuration
There are some configuration options you can provide either inside config/environment.rb or config/environments/$RAILS_ENV.rb or create an initializer in config/initializers.
At least you have to provide your lettr login credentials:

    config/environment.rb:
    config.after_initialize do
      Lettr.credentials = { :user => 'tea_moe', :pass => 'iwonttellyou' }
    end

    OR

    config/initializers/lettr.rb
    Lettr.credentials = { :user => 'tea_moe', :pass => 'iwonttellyou' }

Additional configuration options include:
    Lettr.protocol
    Lettr.host
but for most use cases the defaults are fine, so you dont have to provide them.

## Usage (EMail delivery)
There are currently several ways of using this gem.

### Delivery Method
Just set the Delivery Method of ActionMailer to :lettr, and all Mailings from Action Mailer will be delivered through our API.

    config.action_mailer.delivery_method = :lettr
### OR
### Lettr::Mailer
Let your mailer class inherit from Lettr::Mailer instead of ActionMailer::Base.

    class BookingMailer < Lettr::Mailer
      FROM = 'intervillas <info@intervillas-florida.com>'
      def submission_mail(booking)
        recipients booking.email
        from FROM
        subject I18n.t('booking_mailer.ihre_anfrage')
        body :booking => booking
      end
    end

### OR
### Manual Mailing

    Lettr.test_mail(:recipient => 'tg@digineo.de', :subject => 'hi', :test => 'some text', :html => 'some html').deliver

### OR
### With templates stored at lettr.de

#### and a hash
Provide a hash containing the variables, that you used in your template.

    Lettr.test_mail(:test => { :variable_1 => 'foo', :variable_2 => 'bar' }).deliver

#### OR
#### and an object, which responds to :to_nb_hash

    class TestClass
      def to_nb_hash
        { :variable_1 => 'foo', :variable_2 => 'bar' }
      end
    end

    test_object = TestClass.new

    Lettr.test_mail(:test => test_object ).deliver

#### OR
#### automagic
If your provided object does not respond to :to_nb_hash, Lettr will try to automatically serialize it based on the variables you used inside your template.
Given the following Class Definition:

    class TestClass
      def variable_1
        'foo'
      end
      def variable_2
        'bar'
      end
    end

And the following Template:

    "{{test.variable_1}} - {{test.variable_2}}"

When you do a request to the Lettr Api

    test_object = TestClass.new
    Lettr.test_mail(:test => test_object ).deliver

Lettr will invoke the methods :variable_1 and :variable_2 on test_object and serialize their return values for the request.
So the request will result in the following Mailing:

    "foo - bar"

##### Whitelisting Methods
For extra Security it is recommended that you extend your Class with the Lettr::Whitelist module.
It provides a class-level helper method to allow any instance method in your templates.

    class TestClass
      extend Lettr::Whitelist

      nb_white_list :variable_1

      def variable_1
        'foo'
      end
      def variable_2
        'bar'
      end
    end

In this example the call to :variable_1 will be ok, but the call to :variable_2 will raise an Exception.

## Usage (Newsletter Administration)

### Subscribe
In addition to the EMail delivery functionality this gem provides an easy way to sign your users up for your Newsletters.
To sign a user up, just call Lettr.sign_up and provide an object which at least responds to an :email method.

    class User < ActiveRecord::Base
    ...
      after_create do |user|
        if user.wants_spam?
          Lettr.subscribe(user) # calls user.email internally
        end
      end
    ...
    end

This will create a Recipient in lettr.de. If the provided object responds to:

    :gender
    :firstname
    :lastname
    :street
    :ccode
    :pcode
    :city

these attributes will also get transmitted to lettr.de.
If your object doesnt respond to these methods, but you want the information in your Recipients database, make the object respond (for example by delegating).

### Unsubscribe
To unsubscribe a Recipient, just call Lettr.unsubscribe and provide an email-address as argument.

    Lettr.unsubscribe('tea_moe@example.com')

Copyright (c) 2010 Digineo GmbH, released under the MIT license
