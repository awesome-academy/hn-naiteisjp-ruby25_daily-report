require "rails_helper"

RSpec.describe StaticPagesController, type: :controller do
  describe "GET #help" do
    context "when user is logged in" do
      context "with user role" do
        let(:user) { create(:user, active: true) }

        before do
          sign_in user
          get :help, params: { locale: :en }
        end

        it "redirects to user dashboard page" do
          expect(response).to redirect_to(user_dashboard_show_path)
        end
      end

      context "with manager role" do
        let(:manager) { create(:user, :manager, active: true) }

        before do
          sign_in manager
          get :help, params: { locale: :en }
        end

        it "redirects to manager dashboard page" do
          expect(response).to redirect_to(manager_dashboard_show_path)
        end
      end

      context "with admin role" do
        let(:admin) { create(:user, :admin, active: true) }

        before do
          sign_in admin
          get :help, params: { locale: :en }
        end

        it "redirects to admin dashboard page" do
          expect(response).to redirect_to(admin_dashboard_show_path)
        end
      end
    end

    context "when user is not logged in" do
      before do
        get :help, params: { locale: :en }
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
