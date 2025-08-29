require "rails_helper"

RSpec.describe RegistrationsController, type: :controller do
  let(:user) { create(:user, active: true) }

  before {
    sign_in user
  }

  describe "PATCH #update" do
    context "with valid params" do
      it "updates the user and redirects to profile_path" do
        patch :update, params: { user: { email: "new_email@example.com", current_password: user.password } }
        expect(user.reload.email).to eq("new_email@example.com")
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid params" do
      it "renders edit with errors" do
        patch :update, params: { user: { email: "", current_password: user.password } }
        expect(response).to render_template("registrations/edit")
        expect(response.status).to eq(422)
      end
    end
  end
end
