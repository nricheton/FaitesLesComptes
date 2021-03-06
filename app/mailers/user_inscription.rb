
# Classe permettant d'envoyer un mail pour signaler un nouvel inscrit
# 
class UserInscription < ActionMailer::Base
  default :from=>ENV['MAIL_USER_NAME']

  # renvoie au template new_user_advice qui est dans views/new_user_advice 
  def new_user_advice(user)
    @user = user
    mail(
      :to=>ENV['MAIL_USER_NAME'],
      :subject=>'ouverture d\'un nouveau compte')
  end
  
  def welcome_user(user)
    @user = user
    mail(
      :to=>user.email,
      :subject=>'Bienvenue sur FaitesLesComptes !')
  end

end
