NewsletterBoy::ApiMailing = Struct.new(:identifier, :subject, :variables) do
  include NewsletterBoy::Resource
  include NewsletterBoy::ObjectConverter

  attr_writer :options

  self.path = 'api_mailings'

  def initialize attributes={}
    attributes['api_mailing'].each do |key, value|
      send("#{key}=", value)
    end
  end

  def deliver
    fail ArgumentError, 'Empfänger nicht übergeben' unless @options.has_key?(:recipient)
    rec = build_delivery_record
    rec.save
    if rec.errors.any?
      # invalidate cache and retry
      old_recipient = @hash[:recipient]
      reload
      @options[:recipient] = old_recipient
      rec = build_delivery_record
      rec.save
    end
    rec
  end

  def reload
    self.send(:initialize, 'api_mailing' => self.class.find(identifier).attributes)
  end

  def build_delivery_record
    build_initial_delivery_hash
    @options.stringify_keys!
    group_variables
    handle_options
    append_used_variables

    # perform delivery request
    rec = NewsletterBoy::Delivery.new @hash, @files
    rec
  end

  def append_used_variables
    @hash.merge! :variables => variables
  end

  def build_initial_delivery_hash
    @hash = {}
    @files = {}
    @hash[ :recipient ] = @options.delete(:recipient)
    @hash[ :api_mailing_id ] = identifier
  end

  def group_variables
    @vars = {}
    variables.each do |var|
      methods = var.match(/^(\w+)\..+/)
      @vars[methods[1]] ||= []
      @vars[methods[1]] << var
    end
  end

  def handle_options
    # handle options
    @options.each do |name, object|
      case
      when object.is_a?( Hash )
        # variablen als @hash übergeben
        @hash.merge!( name => object )
      when object.respond_to?( :to_nb_hash )
        # object liefert variablen
        @hash.merge!( name => object.to_nb_hash)
      when object.is_a?( String )
        @files.merge!( name => File.new(object, 'rb'))
      else
        # do magic stuff
        @hash.merge!(options_to_hash(name))
      end
    end
  end

end
