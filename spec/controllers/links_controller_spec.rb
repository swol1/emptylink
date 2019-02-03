require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  let(:user) {User.create!(email: 'test@test.ru', password: '123456')}
  let(:valid_attributes) {{'url' => 'l.goodprogrammer.ru', 'user_id' => user.id}}
  let(:invalid_attributes) {{'url' => '/l.goodprogrammer.ru'}}
  let(:link) {Link.create!(valid_attributes)}

  describe 'GET #open' do
    it 'increments counter' do
      expect {get :open, params: {short_url: link.name}}.to change {link.reload.clicks}.by(1)
    end

    it 'redirects with HTTP 301' do
      get :open, params: {short_url: link.name}
      expect(response).to redirect_to(link.url)
      expect(response.status).to eq(301)
    end
  end

  describe 'PUT #update' do
    before(:each) {sign_in user}

    let(:new_attributes) {{'name' => '123_a', 'url' => 'http://www.ya.ru'}}

    it 'updates the requested link & redirects to its page' do
      put :update, params: {id: link.to_param, link: new_attributes}
      link.reload
      expect(link.attributes).to include(new_attributes)
      expect(response).to redirect_to(link)
    end

    it 'rejects invalid attributes' do
      put :update, params: {id: link.to_param, link: invalid_attributes}
      link.reload
      expect(link.attributes).not_to include(new_attributes)
      expect(assigns(:link)).to eq(link)
      expect(response).to render_template('edit')
    end
  end

  describe 'DELETE #destroy' do
    before(:each) {sign_in user}

    it 'destroys the requested link' do
      link
      expect {
        delete :destroy, params: {id: link.to_param}
      }.to change(Link, :count).by(-1)
      expect(response).to redirect_to(links_url)
    end
  end

  describe 'POST #create' do
    context 'without authenticated user' do
      it 'doesnt create a Link w/o User' do
        expect {
          post :create, params: {link: valid_attributes}
        }.not_to change(Link, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with authenticated user' do
      before(:each) {sign_in user}

      it 'creates new Link with User' do
        post :create, params: {link: valid_attributes}
        link = Link.find(assigns(:link).id)
        expect(link.user).to eq user
        expect(response).to redirect_to(link)
      end

      it 'assigns a newly created but unsaved link as @link' do
        post :create, params: {link: invalid_attributes}
        expect(assigns(:link)).to be_a_new(Link)
        expect(response).to render_template('new')
      end
    end
  end
end
