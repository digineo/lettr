class NewsletterBoy::ApiMailing < NewsletterBoy::Base
  attr_writer :object, :recipient

  def deliver
    rec = NewsletterBoy::Delivery.new object_to_hash.merge(:recipient => @recipient, :api_mailing_id => identifier)
    rec.save
    rec
  end

  def object_to_hash
    hash = {}
    @collections = {}
    variables.each do |var|
      methods = var.split('.')
      if is_collection_variable?(methods.first)
        handle_collection_variable(methods.first, var)
      else
        handle_methods(methods, hash)
      end
    end
    evaluate_collections
    p hash
    hash
  end

  def handle_methods methods, hash
    method_call = methods.last
    context = hash
    object_context = @object
    methods.each_with_index do |method, index|
      case method
      # collection variable
      when /(\w+)\[([\w\.]+)\]/
        collection_name = $1
        variable_name = $2
        handle_new_collection context, object_context, collection_name, variable_name
      # methoden aufruf (letztes element in der kette)
      when method_call
        context[method] = object_context.send(method)
      # zwischenaufruf 
      else
        context[method] = {} unless context[method]
        context = context[method]
        object_context = object_context.send(method) unless index == 0
      end
    end
  end

  def handle_new_collection context, object_context, collection_name, variable_name
    collection = object_context.send(collection_name)
    context[collection_name] = []
    @collections[variable_name] = Collection.new collection, context[collection_name]
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
