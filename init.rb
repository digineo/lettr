if defined? ActionMailer::Base
  ActionMailer::Base.send(:include, Lettr::ActionMailer)
end
