# Lettr
Deliver your Emails inside your application through the lettr.de API.

## Usage
There are currently 5 ways of using this gem.

### Delivery Method
Just set the Delivery Method of ActionMailer to :lettr, and all Mailings from Action Mailer will be delivered through our API.

    config.action_mailer.delivery_method = :lettr

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

### Manual Mailing

    Lettr.test_mail(:recipient => 'tg@digineo.de', :subject => 'hi', :test => 'some text', :html => 'some html').deliver

### With templates stored at lettr.de

#### and a hash
Provide a hash containing the variables, that you used in your template.

    Lettr.test_mail(:test => { :variable_1 => 'foo', :variable_2 => 'bar' }).deliver

#### and an object, which responds to :to_nb_hash

    class TestClass
      def to_nb_hash
        { :variable_1 => 'foo', :variable_2 => 'bar' }
      end
    end

    test_object = TestClass.new

    Lettr.test_mail(:test => test_object ).deliver

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

Copyright (c) 2010 Digineo GmbH, released under the MIT license
