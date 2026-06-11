class ApplicationMailer < ActionMailer::Base
  default from: ENV["SMTP_DEFAULT_FROM"] || ENV["SMTP_USERNAME"] || Rails.application.credentials.dig(:smtp, :username) || "soporte@marcaya.com"
  layout "mailer"
end
