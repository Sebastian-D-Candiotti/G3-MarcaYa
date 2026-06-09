class ApplicationMailer < ActionMailer::Base
  default from: ENV["SMTP_DEFAULT_FROM"] || ENV["SMTP_USERNAME"] || "soporte@marcaya.com"
  layout "mailer"
end
