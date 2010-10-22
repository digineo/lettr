class NewsletterBoy::ApiMailing < NewsletterBoy::Base
  attr_writer :options

  def deliver
    fail ArgumentError, 'Empfänger nicht übergeben' unless @options.has_key?(:recipient)
    rec = build_delivery_record
    begin
      rec.save
    rescue ActiveResource::MethodNotAllowed => e
      old_recipient = @hash[:recipient]
      self.id = identifier
      self.reload
      @options[:recipient] = old_recipient
      rec = build_delivery_record
      rec.save
    end
  end

  def build_delivery_record
    build_initial_delivery_hash
    @options.stringify_keys!
    group_variables
    handle_options
    append_used_variables

    # perform delivery request
    rec = NewsletterBoy::Delivery.new @hash
    rec
  end

  def append_used_variables
    @hash.merge! :variables => variables
  end

  def build_initial_delivery_hash
    @hash = {}
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
      else
        # do magic stuff
        @hash.merge!(options_to_hash(name))
      end
    end
  end

  def options_to_hash name
    hash = {}
    @collections = {}
    @vars[name.to_s].each do |var|
      methods = var.split('.')
      #if is_collection_variable?(methods.first)
      #handle_collection_variable(methods.first, var)
      #else
      handle_methods(methods, hash)
      #end
    end
    evaluate_collections
    hash
  end

  def handle_methods methods, hash
    method_call = methods.last
    context = hash
    object_context = @options
    methods.each_with_index do |method, index|
      #object_context = @options[method] if index == 0
      case method
        # collection variable
      when /(\w+)\[([\w\.]+)\]/
        collection_name = $1
        variable_name = $2
        if method == method_call
          handle_new_collection context, object_context, collection_name, variable_name
        else
          if is_collection_variable? methods[index+1]
            handle_collection_variable( methods[index+1], methods.join('.') )
            break
          end
        end

        # methoden aufruf (letztes element in der kette)
      when method_call
        if object_context.class.respond_to? :is_whitelisted?
          raise SecurityError, "method #{method_call} in class #{object_context.class} not whitelisted" unless object_context.class.is_whitelisted?(method)
        else
          warn "no whitelist in class #{object_context.class}"
        end
        context[method] = object_context.send(method)
        # zwischenaufruf 
      else
        context[method] = {} unless context[method]
        context = context[method]
        object_context = index == 0 ? object_context[method] : object_context.send(method)
      end
    end
  end

  def handle_new_collection context, object_context, collection_name, variable_name
    collection = object_context.send(collection_name)
    context[collection_name] = []
    @collections[variable_name] = NewsletterBoy::Collection.new collection, context[collection_name]
  end

  def evaluate_collections
    @collections.each do |key, collection|
      collection.evaluate
    end
  end

  def is_collection_variable? variable_name
    @collections.has_key?( variable_name )
  end

  def handle_collection_variable variable_name, full_variable_name
    @collections[variable_name].add_variable(full_variable_name)
  end

end
