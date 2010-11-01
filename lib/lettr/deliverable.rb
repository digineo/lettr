module NewsletterBoy::Deliverable

  def self.included base
    base.class_eval do
      attr_accessor :recipient
    end
  end

  def recipient?
    !!@recipient
  end

  def deliver
    fail ArgumentError, 'Empfänger nicht übergeben' unless recipient?
    rec = build_delivery_record
    rec.save
    if rec.errors.any?
      # invalidate cache and retry
      old_recipient = @hash[:recipient]
      reload
      recipient = old_recipient
      rec = build_delivery_record
      rec.save
    end
    rec
  end

  def build_delivery_record
    build_initial_delivery_hash
    group_variables if respond_to? :group_variables
    handle_options
    append_used_variables if respond_to? :append_used_variables

    # perform delivery request
    rec = NewsletterBoy::Delivery.new @hash, @files
    rec
  end

  def build_initial_delivery_hash
    @hash = {}
    @files = {}
    @hash[ :recipient ] = recipient
    @hash[ :api_mailing_id ] = identifier
  end

end
