# encoding: utf-8
require 'active_support'
require 'rest-client'

module Lettr

  autoload :Base, 'lettr/base'
  autoload :Resource, 'lettr/resource'
  autoload :Recipient, 'lettr/recipient'
  autoload :Deliverable, 'lettr/deliverable'
  autoload :ObjectConverter, 'lettr/object_converter'
  autoload :ApiMailing, 'lettr/api_mailing'
  autoload :Delivery, 'lettr/delivery'
  autoload :Collection, 'lettr/collection'
  autoload :RenderedMailing, 'lettr/rendered_mailing'
  autoload :Whitelist, 'lettr/whitelist'
  autoload :ActionMailer, 'lettr/action_mailer'
  autoload :Mailer, 'lettr/mailer'
  autoload :MailExtensions, 'lettr/mail_extensions'
  #require 'lettr/mail_extensions'
  #require 'lettr/railtie' if defined? Rails::Railtie

  mattr_accessor :host
  mattr_accessor :attributes
  mattr_accessor :protocol
  mattr_accessor :api_key

  self.attributes ||= %w{ gender firstname lastname street ccode pcode city }
  self.protocol ||= 'https'
  self.host ||= 'lettr.de'

  def self.credentials=(credentials)
    Lettr::Base.user = credentials[:user]
    Lettr::Base.pass = credentials[:pass]
  end

  class << self
  %w{ subscribe unsubscribe }.each do |meth|
    define_method meth do |*args|
      Lettr::Base.send(meth, *args)
    end
  end
  end

  def self.method_missing *args, &block
    if args.first.to_s =~ /^to_/
      super
    end
    Lettr::Base.load_api_mailing_or_fail_loud *args
  rescue RestClient::ResourceNotFound
    super
  end

end

if defined? Rails::Railtie
  class Lettr::Railtie < Rails::Railtie

    initializer 'lettr.init' do
      ActiveSupport.on_load(:action_mailer) do
        ActionMailer::Base.add_delivery_method :lettr, Lettr::MailExtensions::Lettr
      end
    end

  end
end
