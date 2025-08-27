require "rails_helper"

RSpec.describe Manager::DashboardController, type: :controller do
  describe "GET #show" do
    context "when logged in as a manager" do
      context "and has a department" do
        let(:manager) { create(:user, :manager_with_department, active: true) }
        let(:department) { manager.department }

        before do
          create_list(:user, 2, department: department, active: true)
          create(:user, department: department, active: false)
          create(:daily_report, receiver: manager, status: :pending)
          create(:daily_report, :read, receiver: manager)

          sign_in manager
          get :show
        end

        it "assigns the correct department to @department" do
          expect(assigns(:department)).to eq(department)
        end

        it "assigns the correct number of active users to @active_users_count" do
          expect(assigns(:active_users_count)).to eq(2)
        end

        it "assigns the correct number of pending reports to @pending_reports_count" do
          expect(assigns(:pending_reports_count)).to eq(1)
        end

        it "renders the 'show' template" do
          expect(response).to render_template(:show)
        end

        it "returns a successful response" do
          expect(response).to have_http_status(:success)
        end
      end

      context "and does not have a department" do
        let(:manager_no_dept) { create(:user, :manager, department: nil, active: true) }

        before do
          sign_in manager_no_dept
          get :show
        end

        it "assigns @department as nil" do
          expect(assigns(:department)).to be_nil
        end

        it "does not assign a value to @active_users_count" do
          expect(assigns(:active_users_count)).to be_nil
        end

        it "renders the 'show' template" do
          expect(response).to render_template(:show)
        end
      end
    end

    context "when logged in with a non-manager role" do
      let(:user) { create(:user, active: true) }

      before do
        sign_in user
        get :show
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_url)
      end

      it "displays an error message" do
        expect(flash[:warning]).to eq(I18n.t("users.errors.no_right"))
      end
    end
  end
end
