# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
OaAuto::Application.initialize!
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.server_settings = {
   :address => "smtp.live.com",
   :port => 25,
   # :domain => "tutorialspoint.com",
   :authentication => :login,
   :user_name => "shuangbi.zhang",
   :password => "Jinzhou0416"
}