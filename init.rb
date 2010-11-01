# Include hook code here
#if defined? ActionMailer::Base
  ActionMailer::Base.send(:include, Lettr::ActionMailer)
#end

puts 'init.rb'
