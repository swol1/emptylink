# По аналогии с LinkPolicy делаем политику для пользователя
class UserPolicy < ApplicationPolicy
  # Смотреть юзера может только он сам или админ
  def show?
    user.present? && (user == record || user.admin?)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
