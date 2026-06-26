class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAIL_FROM"] || ENV["SMTP_DEFAULT_FROM"] || ENV["SMTP_USERNAME"] || Rails.application.credentials.dig(:smtp, :username) || "onboarding@resend.dev"
  layout "mailer"
end
