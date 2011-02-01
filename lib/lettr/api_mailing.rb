class Lettr::ApiMailing < Struct.new(:identifier, :subject, :variables)
  include Lettr::Resource
  include Lettr::ObjectConverter
  include Lettr::Deliverable

  self.path = 'api_mailings'

  attr_writer :delivery_options

  def initialize attributes={}
    attributes['api_mailing'].each do |key, value|
      send("#{key}=", value)
    end
  end

  def delivery_options= options
    @recipient = options.delete(:recipient)
    @delivery_options = options
    @delivery_options.stringify_keys!
  end

  def reload
    self.send(:initialize, 'api_mailing' => self.class.find(identifier).attributes)
  end

  def append_used_variables
    @hash.merge! :variables => variables
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
    @delivery_options.each do |name, object|
      case
      when object.is_a?( Hash )
        # variablen als @hash übergeben
        @hash.merge!( name => object )
      when object.respond_to?( :to_nb_hash )
        # object liefert variablen
        @hash.merge!( name => object.to_nb_hash)
      when object.is_a?( String )
        if name.to_s == 'text' || name.to_s == 'html'
          raise ArgumentError.new 'You cannot use Delivery Method, Lettr::Mailer or Manual Mailing with existing identifiers.'
        end
        @files.merge!( name => File.new(object, 'rb'))
      else
        # do magic stuff
        @hash.merge!(options_to_hash(name))
      end
    end
  end

end
