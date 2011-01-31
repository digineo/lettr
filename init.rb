if defined? ActionMailer::Base
  if defined? TMail
    ActionMailer::Base.send(:include, Lettr::ActionMailer)
  elsif defined? Mail
    require 'lettr/mail_extensions'
    ActionMailer::Base.add_delivery_method :lettr, Mail::Lettr
  end
end
