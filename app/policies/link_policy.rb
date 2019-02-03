# (c) goodprogrammer.ru
#
# Политика для описания ограничений доступа к моделям Link
class LinkPolicy < ApplicationPolicy
  # можно создать ссылку, если есть юзер (залогинен)
  def create?
    user.present?
  end

  # Смотреть, обновлять и удалять ссылки могут только их владельцы
  # Админы также могут делать что угодно с любой ссылкой
  def destroy?
    update?
  end

  def show?
    update?
  end

  def update?
    user_is_owner?(record) || user.admin?
  end

  # Выбирает из исходного скоупа только ссылки, принадлежащие юзеру
  class Scope < Scope
    def resolve
      if user.present?
        # Если пользователь — админ, показываем все ссылки,
        # иначе только те, что создал сам юзер
        user.admin? ? scope.all : scope.where(user: user)
      end
    end
  end

  private

  def user_is_owner?(link)
    user.present? && (link.try(:user) == user)
  end
end
