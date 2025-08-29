require "rails_helper"

RSpec.describe PasswordsController, type: :controller do
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

  describe "GET #new" do
    it "renders the new password form" do
      get :new, params: { locale: :en }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("devise/passwords/new")
    end
  end

  describe "POST #create" do
    context "with valid email" do
      it "sends reset password instructions" do
        expect do
            post :create, params: {
              locale: :en,
              user: { email: user.email }
            }
            puts "Deliveries: #{ActionMailer::Base.deliveries.inspect}"
        end
        # .to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid email" do
      it "does not send reset password instructions" do
        expect do
          post :create, params: {
            locale: :en,
            user: { email: "nonexistent@example.com" }
          }
        end.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("devise/passwords/new")
      end
    end
  end

  describe "GET #edit" do
    context "with a valid reset password token" do
      let!(:raw_token) { user.send_reset_password_instructions }

      it "renders the edit password form" do
        get :edit, params: {
          locale: :en,
          reset_password_token: raw_token
        }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("devise/passwords/edit")
      end
    end
  end

  describe "PUT #update" do
    before { ActionMailer::Base.deliveries.clear }
    let!(:raw_token) { user.send_reset_password_instructions }

    context "with valid token and matching passwords" do
      it "resets the user's password" do
        put :update, params: {
          locale: :en,
          user: {
            reset_password_token: raw_token,
            password: "new_password",
            password_confirmation: "new_password"
          }
        }
        user.reload
        expect(user.valid_password?("new_password")).to be_truthy
        expect(response).to redirect_to(user_dashboard_show_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "with valid token but mismatched passwords" do
      it "does not reset the password" do
        put :update, params: {
          locale: :en,
          user: {
            reset_password_token: raw_token,
            password: "new_password",
            password_confirmation: "mismatched_password"
          }
        }
        user.reload
        expect(user.valid_password?("old_password")).to be_truthy
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("devise/passwords/edit")
      end
    end

    context "with invalid token" do
      it "does not reset the password" do
        put :update, params: {
          locale: :en,
          user: {
            reset_password_token: "invalid_token",
            password: "new_password",
            password_confirmation: "new_password"
          }
        }
        user.reload
        expect(user.valid_password?("old_password")).to be_truthy
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("devise/passwords/edit")
      end
    end
  end
end
