require 'active_support'

module Lettr

  require 'lettr/base'
  require 'lettr/resource'
  require 'lettr/recipient'
  require 'lettr/deliverable'
  require 'lettr/object_converter'
  require 'lettr/api_mailing'
  require 'lettr/delivery'
  require 'lettr/collection'
  require 'lettr/rendered_mailing'
  require 'lettr/whitelist'

  mattr_accessor :host
  mattr_accessor :attributes
  mattr_accessor :protocol
  mattr_accessor :api_mailings

  self.attributes ||= %w{ gender firstname lastname street ccode pcode city }
  self.protocol ||= 'http'
  self.host ||= 'www.newsletterboy.de'
  self.api_mailings = {}

  def self.credentials=(credentials)
    Base.user = credentials[:user]
    Base.pass = credentials[:pass]
  end

  def self.subscribe(recipient)
    raise 'Object muss über das Attribut :email verfügen.' unless recipient.respond_to? :email
    rec = Recipient.new recipient.email
    attributes.each do |attribute|
      if recipient.respond_to? attribute
        rec.send("#{attribute}=", recipient.send(attribute))
      end
    end
    rec.approved = true
    unless rec.save
      raise rec.errors.join(' ')
    end
    rec
  end

  def self.unsubscribe(email)
    Recipient.delete_by_email(email)
  end

  def self.load_api_mailing_or_fail_loud *args
    identifier = args[0]
    api_mailing = self.api_mailings[identifier] ||= ApiMailing.find(identifier)
    options = args[1]
    api_mailing.delivery_options = options
    return api_mailing
  rescue RestClient::ResourceNotFound => e
    _create_rendered_mail( *args )
  end

  def self._check_options_for_rendered_mail! options
    [:subject, :recipient].each do |opt|
      raise ArgumentError.new ":#{opt} is required" unless options.has_key?( opt )
    end
    raise ArgumentError.new ":html or :text is required" unless (options.has_key?( :text ) || options.has_key?( :html ))
  end

  def self._create_rendered_mail *args
    _check_options_for_rendered_mail! args[1]
    mailing = RenderedMailing.find args[0].to_s
    mailing.attributes = args[1].merge(:identifier => args[0].to_s)
    mailing
  rescue RestClient::ResourceNotFound
    mailing = RenderedMailing.new args[1].merge(:identifier => args[0].to_s)
    unless mailing.save
      raise ArgumentError.new mailing.errors.join(' ')
    end
    mailing
  end

  def self.api_mailings
    @@api_mailings
  end

  def self.method_missing *args, &block
    load_api_mailing_or_fail_loud *args
  rescue RestClient::ResourceNotFound
    super
  end

end
