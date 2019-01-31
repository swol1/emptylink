# Main links controller: creates and runs all the links
#
# (c) goodprogrammer.ru
#
class LinksController < ApplicationController
  before_action :authenticate_user!, except: [:open, :new, :create]
  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_action :set_shortlink, only: [:open]
  before_action :set_linkdomain, only: [:create]

  def open
    # increment clicks counter — in an atomic/thread-safe way
    Link.increment_counter(:clicks, @link.id)
    redirect_to @link.url, status: :moved_permanently
  end

  # GET /links
  # GET /links.json
  def index
    @links = Link.all
  end

  # GET /links/1
  # GET /links/1.json
  def show
  end

  # GET /links/new
  def new
    @link = Link.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = Link.new(link_params)
    @link.user = current_user
    @link.domain = @domain

    respond_to do |format|
      if @link.save
        # TBD: move to i18n strings
        format.html {redirect_to @link, notice: 'Link was successfully created.'}
        format.json {render :show, status: :created, location: @link}
      else
        format.html {render :new}
        format.json {render json: @link.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    respond_to do |format|
      if @link.update(link_params)
        # TBD: move to i18n strings
        format.html {redirect_to @link, notice: 'Link was successfully updated.'}
        format.json {render :show, status: :ok, location: @link}
      else
        format.html {render :edit}
        format.json {render json: @link.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link.destroy
    respond_to do |format|
      # TBD: move to i18n strings
      format.html {redirect_to links_url, notice: 'Link was successfully destroyed.'}
      format.json {head :no_content}
    end
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
    # domain = // TBD: only tubi.ru domain for now
    @link = Link.where(name: name, domain: nil).take
  end

  # set Link domain name (for custom domains feature)
  # empty string by default -- meaning current app tubi.ru domain
  def set_linkdomain
    @domain = nil
  end
end
