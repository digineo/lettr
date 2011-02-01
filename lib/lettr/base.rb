# encoding: utf-8
module Lettr
  class Base
    DEFAULT_HEADERS = { :accept => :json }

    cattr_accessor :site, :user, :pass, :content_type, :api_mailings
    attr_reader :client

    self.api_mailings = {}

    def initialize
      resource_args = [ self.class.site_url ]
      resource_args += [self.class.user, self.class.pass] unless Lettr.api_key
      @client = RestClient::Resource.new *resource_args
    end

    def self.site_url
      "#{Lettr.protocol}://#{Lettr.host}/"
    end

    def save object
      path = object.collection_path
      payload = object.to_payload
      payload.merge! :files => object.files if object.respond_to?(:files) && object.files
      client[path].post(payload, headers)
    end

    def destroy object
      client[object.path].delete headers
    end

    def find path
      ActiveSupport::JSON.decode(client[path].get headers)
    end

    def [] path
      client[path]
    end

    def headers
      headers = DEFAULT_HEADERS
      headers.merge! 'X-Lettr-API-key' => Lettr.api_key if Lettr.api_key
      headers
    end

    def self.subscribe(recipient)
      raise 'Object muss über das Attribut :email verfügen.' unless recipient.respond_to? :email
      rec = Lettr::Recipient.new recipient.email
      Lettr.attributes.each do |attribute|
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
      Lettr::Recipient.delete_by_email(email)
    end

    def self.load_api_mailing_or_fail_loud *args
      identifier = args[0]
      api_mailing = self.api_mailings[identifier] ||= Lettr::ApiMailing.find(identifier)
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
      mailing = Lettr::RenderedMailing.find args[0].to_s
      mailing.attributes = args[1].merge(:identifier => args[0].to_s)
      mailing
    rescue RestClient::ResourceNotFound
      mailing = Lettr::RenderedMailing.new args[1].merge(:identifier => args[0].to_s)
      unless mailing.save
        raise ArgumentError.new mailing.errors.join(' ')
      end
      mailing
    end

    def self.api_mailings
      @@api_mailings
    end

  end

end


