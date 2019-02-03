require 'rails_helper'

RSpec.describe LinkPolicy do
  let(:user) { User.new }

  # объект тестирования (политика)
  subject { LinkPolicy }

  context 'when user in not an owner' do
    # Тестируем относительно анонимной ссылки в этом контексте
    let(:link) {Link.create(url: 'goodprogrammer.ru')}

    permissions :create? do
      it { is_expected.to permit(user, Link) }
      it { is_expected.not_to permit(nil, Link) }
    end

    permissions :show?, :edit?, :update?, :destroy? do
      it { is_expected.not_to permit(user, link) }
    end
  end

  context 'when user in an owner' do
    # Тестируем относительно ссылки этого юзера в этом контексте
    let(:link) { Link.create(url: 'goodprogrammer.ru', user: user) }

    permissions :show?, :edit?, :update?, :destroy? do
      it { is_expected.to permit(user, link) }
    end
  end

  context 'when user is an admin' do
    # Создаем админа и подставляем его в качестве пользователя
    let(:admin) { User.new(admin: true) }
    let(:link) { Link.create(url: 'goodprogrammer.ru', user: user) }

    # Админу должно быть можно делать со ссылкой все
    permissions :show?, :edit?, :update?, :destroy? do
      it { is_expected.to permit(admin, link) }
    end
  end
end
