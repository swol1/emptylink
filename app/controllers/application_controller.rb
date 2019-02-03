class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Pundit # подключить функционал Пандита ко всем контроллерам

  # Обработать ошибку авторизации
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    # Перенаправляем юзера откуда пришел (или в корень сайта)
    # с сообщением об ошибке (для секьюрности сообщение ЛУЧШЕ опустить!)
    flash[:alert] = t('pundit.not_authorized')
    redirect_to(request.referrer || root_path)
  end
end
