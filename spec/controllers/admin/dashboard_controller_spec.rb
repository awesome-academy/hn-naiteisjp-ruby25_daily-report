require "rails_helper"

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin){create(:user, role: :admin, active: true)}

  before do
    sign_in admin
  end

  describe "GET #show" do
    let!(:departments){create_list(:department, 3, :without_manager)}
    let!(:managers){create_list(:user, 2, role: :manager)}
    let!(:users){create_list(:user, 5, role: :user)}

    before do
      get :show
    end

    it "assigns the correct value to @departments_count" do
      expect(assigns(:departments_count)).to eq(3)
    end

    it "assigns the correct value to @managers_count" do
      expect(assigns(:managers_count)).to eq(2)
    end

    it "assigns the correct value to @users_count" do
      expect(assigns(:users_count)).to eq(5)
    end

    it "renders the 'show' template" do
      expect(response).to render_template(:show)
      expect(response).to have_http_status(:success)
    end
  end
end
