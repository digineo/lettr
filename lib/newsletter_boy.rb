module NewsletterBoy

  mattr_accessor :host
  mattr_accessor :attributes
  mattr_accessor :protocol

  self.attributes = %w{ gender firstname lastname street ccode pcode city }
  self.protocol = 'https'
  self.host = 'www.newsletterboy.de'

  class Base < ActiveResource::Base
    self.format = :json
  end

  class Recipient < Base
  end

  class ApiMailing < Base
    attr_writer :object, :recipient

    def deliver
      rec = Delivery.new object_to_hash.merge(:recipient => @recipient, :api_mailing_id => identifier)
      rec.save
      rec
    end

    def object_to_hash
      hash = {}
      variables.each do |var|
        methods = var.split('.')
        method_call = methods.last
        context = hash
        object_context = @object
        methods.each_with_index do |method, index|
          unless method == method_call
            context[method] = {} unless context[method]
            context = context[method]
            object_context = object_context.send(method) unless index == 0
          else
            context[method] = object_context.send(method)
          end
        end
      end
      hash
    end
  end

  class Delivery < Base
    self.prefix = "/api_mailings/:api_mailing_id/"
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


  def self.method_missing *args, &block
    p args
    identifier = args[0]
    api_mailing = ApiMailing.find(identifier)
    p api_mailing
    object = args[1]
    api_mailing.object = object
    api_mailing.recipient = args.last[:recipient]
    return api_mailing
  rescue ActiveResource::ResourceNotFound
    super
  end

end
