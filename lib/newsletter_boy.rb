module NewsletterBoy

  mattr_accessor :host
  mattr_accessor :attributes
  mattr_accessor :protocol

  self.attributes = %w{ gender firstname lastname street ccode pcode city }
  self.protocol = 'https'
  self.host = 'www.newsletterboy.de'

  class Base < ActiveResource::Base
  end

  class Recipient < Base
  end

  def self.credentials=(credentials)
    Base.site = "#{protocol}://#{credentials[:user]}:#{credentials[:pass]}@#{host}/"
  end

  def self.sign_up(recipient)
    raise 'Object muss über das Attribut :email verfügen.' unless recipient.respond_to? :email
    rec = Recipient.new :email => recipient.email
    attributes.each do |attribute|
      if recipient.respond_to? attribute
        rec.send("#{attribute}=", recipient.send(attribute))
      end
    end
    rec.approved = true
    rec.save
    rec
  end

end
