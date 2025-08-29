require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let!(:active_user) do
    User.create!(
      name: "Active User",
      email: "active@example.com",
      password: "123456",
      role: :user,
      active: true
    )
  end

  let!(:inactive_user) do
    User.create!(
      name: "Inactive User",
      email: "inactive@example.com",
      password: "123456",
      role: :user,
      active: false
    )
  end

  describe "POST /users/sign_in" do
    context "when user is active" do
      it "logs in successfully" do
        post :create, params: {
          locale: :en,
          user: { email: active_user.email, password: "123456", remember_me: "0" }
        }

        expect(controller.current_user).to eq(active_user)
        expect(response).to redirect_to(user_dashboard_show_path)
      end
    end

    context "when user is inactive" do
      it "does not log in and redirects with warning" do
        post :create, params: {
          locale: :en,
          user: { email: inactive_user.email, password: "123456" }
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user does not exist" do
      it "redirects back to login" do
        post :create, params: {
          locale: :en,
          user: { email: "nonexistent@example.com", password: "wrong" }
        }

        expect(controller.current_user).to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
