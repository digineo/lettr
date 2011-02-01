if defined? ActionMailer::Base
  if defined? TMail
    ActionMailer::Base.send(:include, Lettr::ActionMailer)
  end
end
