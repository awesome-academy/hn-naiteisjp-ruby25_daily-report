require "rails_helper"

RSpec.describe ProfilesController, type: :controller do
  render_views

  let!(:user) do
    User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "old_password",
      role: :user,
      active: true
    )
  end

  before do
    sign_in user
    allow(controller).to receive(:check_user_role)
  end

  describe "GET #show" do
    it "assigns the current user to @user" do
      get :show, params: { locale: :en }
      expect(assigns(:user)).to eq(user)
    end

    it "renders the show template" do
      get :show, params: { locale: :en }
      expect(response).to render_template(:show)
    end
  end

  describe "GET #edit" do
    it "assigns the current user to @user and renders the edit template" do
      get :edit, params: { locale: :en }
      expect(assigns(:user)).to eq(user)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:valid_params) { { locale: :en, user: FactoryBot.attributes_for(:user, name: "New Name") } }

      it "updates the user's profile" do
        patch :update, params: valid_params
        user.reload
        expect(user.name).to eq("New Name")
      end

      it "sets a success flash message" do
        patch :update, params: valid_params
        expect(flash[:success]).to eq(I18n.t("users.profile.profile_updated"))
      end

      it "redirects to the profile path" do
        patch :update, params: valid_params
        expect(response).to redirect_to(profile_path)
      end
    end
  end
end
