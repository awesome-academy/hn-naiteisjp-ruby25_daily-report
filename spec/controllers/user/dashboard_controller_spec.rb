require "rails_helper"

RSpec.describe User::DashboardController, type: :controller do
  describe "GET #show" do
    context "when logged in as a user" do
      let(:user) { create(:user, active: true) }

      let!(:reports_this_month) do
        [
          create(:daily_report, owner: user, report_date: Date.current),
          create(:daily_report, owner: user, report_date: Date.current - 1.day)
        ]
      end

      let!(:report_last_month) do
        create(:daily_report, owner: user, report_date: Date.current.last_month)
      end

      before do
        sign_in user
        get :show
      end

      it "assigns the correct daily reports for the current month to @daily_reports" do
        expect(assigns(:daily_reports)).to match_array(reports_this_month)
        expect(assigns(:daily_reports)).not_to include(report_last_month)
      end

      it "renders the 'show' template" do
        expect(response).to render_template(:show)
        expect(response).to have_http_status(:success)
      end
    end

    context "when logged in with a non-user role (e.g., admin)" do
      let(:admin) { create(:user, :admin, active: true) }

      before do
        sign_in admin
        get :show
      end

      it "blocks access and redirects to the root page" do
        expect(response).to redirect_to(root_url)
      end

      it "displays an error message (flash warning)" do
        expect(flash[:warning]).to be_present
        expect(flash[:warning]).to eq(I18n.t("users.errors.no_right"))
      end
    end

    context "when not logged in" do
      it "redirects to the login page" do
        get :show, params: { locale: :en }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
