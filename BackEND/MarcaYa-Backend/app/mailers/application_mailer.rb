class ApplicationMailer < ActionMailer::Base
  default from: ENV['SMTP_USERNAME'] || Rails.application.credentials.dig(:smtp, :username) || "onboarding@resend.dev"
  layout "mailer"
end
