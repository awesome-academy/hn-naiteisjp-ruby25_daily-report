class UserMailer < ApplicationMailer
  def welcome_email user, password
    @user = user
    @password = password
    mail(
      to: @user.email,
      subject: t("users.mailers.welcome_email.subject")
    )
  end
end
