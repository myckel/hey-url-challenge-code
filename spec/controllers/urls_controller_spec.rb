require 'rails_helper'

RSpec.describe UrlsController, type: :controller do
  describe 'GET #index' do
    let!(:urls) { FactoryBot.create_list(:url, 10) }

    before { get :index }

    it 'assigns a new URL' do
      expect(assigns(:url)).to be_a_new(Url)
    end

    it 'assigns the latest URLs' do
      expect(assigns(:urls)).to eq(urls.reverse)
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { url: { original_url: 'https://example.com' } } }

      it 'creates a new URL' do
        expect {
          post :create, params: valid_params
        }.to change(Url, :count).by(1)
      end

      it 'redirects to the index page' do
        post :create, params: valid_params
        expect(response).to redirect_to(urls_path)
      end

      it 'sets a success flash message' do
        post :create, params: valid_params
        expect(flash[:success]).to eq('URL created successfully')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { url: { original_url: 'invalid-url' } } }

      it 'does not create a new URL' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Url, :count)
      end

      it 'redirects to the index page' do
        post :create, params: invalid_params
        expect(response).to redirect_to(urls_path)
      end

      it 'sets an error flash message' do
        post :create, params: invalid_params
        expect(flash[:error].join).to include('Original url is not a valid URL')
      end
    end
  end

  describe 'GET #show' do
    let(:url) { FactoryBot.create(:url) }

    it 'assigns the requested URL' do
      get :show, params: { url: url.short_url }
      expect(assigns(:url)).to eq(url)
    end

    it 'assigns analytics data' do
      get :show, params: { url: url.short_url }
      expect(assigns(:daily_clicks)).not_to be_nil
      expect(assigns(:browsers_clicks)).not_to be_nil
      expect(assigns(:platform_clicks)).not_to be_nil
    end

    it 'renders the show template' do
      get :show, params: { url: url.short_url }
      expect(response).to render_template(:show)
    end

    it 'renders a 404 page for non-existent URL' do
      get :show, params: { url: 'non-existent-url' }
      expect(response).to have_http_status(:not_found)
      expect(response).to render_template('_shared/404')
    end
  end

  describe 'GET #visit' do
    let(:url) { FactoryBot.create(:url) }

    it 'assigns the requested URL' do
      get :visit, params: { short_url: url.short_url }
      expect(assigns(:url)).to eq(url)
    end

    it 'performs a click on the URL' do
      expect {
        get :visit, params: { short_url: url.short_url }
      }.to change(Click, :count).by(3)
    end

    it 'redirects to the original URL' do
      get :visit, params: { short_url: url.short_url }
      expect(response).to redirect_to(url.original_url)
    end

    it 'renders a 404 page for non-existent URL' do
      get :visit, params: { short_url: 'non-existent-url' }
      expect(response).to have_http_status(:not_found)
      expect(response).to render_template('_shared/404')
    end
  end
end
