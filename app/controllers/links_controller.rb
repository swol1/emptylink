# Main links controller: creates and runs all the links
#
# (c) goodprogrammer.ru
#
class LinksController < ApplicationController
  before_action :authenticate_user!, except: [:open]

  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_action :set_linkdomain, only: [:create, :open]
  before_action :set_shortlink, only: [:open]

  # Предохранитель от потери авторизации в нужных экшенах
  after_action :verify_authorized, except: [:open, :index]

  # Предохранитель от неиспользования pundit scope в index экшене
  after_action :verify_policy_scoped, only: :index

  def open
    # increment clicks counter — in an atomic/thread-safe way
    Link.increment_counter(:clicks, @link.id)
    redirect_to @link.url, status: :moved_permanently
  end

  def index
    # выбираем из ссылок только принадлежажие current_user-у
    # см. комментарии в LinkPolicy
    @links = policy_scope(Link)
  end

  def show
    # Pundit создает новый экземпляр LinkPolicy.new(current_user, @link)
    # и вызывает у него метод, аналогичный имени текущего экшена: show?
    # если метод политики вернет false — будет брошен эксепшен
    # и действие контроллера не продолжится
    authorize @link
  end

  def new
    @link = Link.new
    authorize @link
  end

  def edit
    authorize @link
  end

  def create
    @link = Link.new(link_params)

    authorize @link

    @link.user = current_user
    @link.domain = @domain

    if @link.save && verify_recaptcha(model: @link)
      # TBD: move to i18n strings
      redirect_to @link, notice: 'Link was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @link

    if @link.update(link_params)
      # TBD: move to i18n strings
      redirect_to @link, notice: 'Link was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @link

    @link.destroy
    # TBD: move to i18n strings
    redirect_to links_url, notice: 'Link was successfully destroyed.'
  end

  private

  def set_link
    @link = Link.find(params[:id])
  end

  def link_params
    params.require(:link).permit(:name, :url)
  end

  # Loads Link model according to domain and param[:short_url] option, see routes.rb
  def set_shortlink
    name = params[:short_url]
    @link = Link.where(name: name, domain: @domain).take
  end

  # set Link domain name (for custom domains feature)
  # empty string by default -- meaning current app tubi.ru domain
  # TBD: only tubi.ru domain for now
  def set_linkdomain
    @domain = nil
  end
end
