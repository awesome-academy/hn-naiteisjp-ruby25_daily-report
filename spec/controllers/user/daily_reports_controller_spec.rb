require "rails_helper"

RSpec.describe User::DailyReportsController, type: :controller do
  let(:user) { create(:user, active: true) }
  let(:manager) { create(:user, :manager) }
  let(:daily_report) { build_stubbed(:daily_report, owner: user, receiver: manager) }
  let(:pagy_result) { [double("Pagy"), [daily_report]] }

  let(:valid_params) do
    {
      daily_report: {
        planned_tasks: "New planned tasks",
        actual_tasks: "Actual tasks completed",
        incomplete_reason: "Some blocking issue",
        next_day_planned_tasks: "Tomorrow's plan",
        report_date: Date.today,
        receiver_id: manager.id
      }
    }
  end

  before do
    sign_in user
    allow(controller).to receive(:check_user_role)
    allow(controller).to receive(:logged_in_user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:belongs_department?)
  end

  describe "GET #new" do
    before do
      allow(user.sent_reports).to receive(:build).and_return(daily_report)
      get :new
    end

    it "builds a new daily report" do
      expect(user.sent_reports).to have_received(:build)
    end

    it "assigns @daily_report" do
      expect(assigns[:daily_report]).to eq(daily_report)
    end

    it "renders new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    before do
      allow(user.sent_reports).to receive(:build).and_return(daily_report)
      allow(daily_report).to receive(:save)
      allow(DailyReportMailer).to receive_message_chain(:notify_manager, :deliver_later)
    end

    context "with valid parameters" do
      before do
        allow(daily_report).to receive(:save).and_return(true)
        post :create, params: valid_params
      end

      it "builds daily report with correct params" do
        expect(user.sent_reports).to have_received(:build)
      end

      it "attempts to save the daily report" do
        expect(daily_report).to have_received(:save)
      end

      it "sends notification email" do
        expect(DailyReportMailer).to have_received(:notify_manager).with(daily_report)
      end

      it "redirects to index" do
        expect(response).to redirect_to(user_daily_reports_path)
      end
    end

    context "with invalid parameters" do
      before do
        allow(daily_report).to receive(:save).and_return(false)
        allow(daily_report).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("Error message")
        post :create, params: valid_params
      end

      it "attempts to save the daily report" do
        expect(daily_report).to have_received(:save)
      end

      it "renders new template with unprocessable_entity status" do
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end

      it "assigns @daily_report" do
        expect(assigns[:daily_report]).to eq(daily_report)
      end
    end
  end

  describe "GET #index" do
    context "when user is logged in" do
      let(:user) { create(:user, active: true) }
      let(:other_user) { create(:user, active: true) }

      let!(:user_reports) { create_list(:daily_report, 2, owner: user) }
      let!(:other_user_report) { create(:daily_report, owner: other_user) }
      before do
        sign_in user
        get :index, params: { locale: :en }
      end

      it "assigns a Ransack search object to @q" do
        expect(assigns(:q)).to be_a(Ransack::Search)
      end

      it "assigns the correct daily reports for the user to @daily_reports" do
        expect(assigns(:daily_reports)).to match_array(user_reports)
        expect(assigns(:daily_reports)).not_to include(other_user_report)
      end

      it "assigns a Pagy object to @pagy" do
        expect(assigns(:pagy)).to be_a(Pagy)
      end

      it "renders the 'index' template" do
        expect(response).to render_template(:index)
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    before do
      allow(DailyReport).to receive(:find).and_return(daily_report)
      get :show, params: { id: 1 }
    end

    it "finds the daily report" do
      expect(DailyReport).to have_received(:find).with("1")
    end

    it "assigns @daily_report" do
      expect(assigns[:daily_report]).to eq(daily_report)
    end

    it "renders show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #edit" do
    before do
      allow(DailyReport).to receive(:find).and_return(daily_report)
      allow(controller).to receive(:check_status)
    end

    context "when daily report exists" do
      before do
        get :edit, params: { id: 1 }
      end

      it "finds the daily report" do
        expect(DailyReport).to have_received(:find).with("1")
      end

      it "calls check_status" do
        expect(controller).to have_received(:check_status)
      end

      it "assigns @daily_report" do
        expect(assigns[:daily_report]).to eq(daily_report)
      end

      it "renders edit template" do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "PATCH #update" do
    before do
      allow(DailyReport).to receive(:find).and_return(daily_report)
      allow(daily_report).to receive(:update)
    end

    context "when update succeeds" do
      before do
        allow(daily_report).to receive(:update).and_return(true)
        patch :update, params: { id: 1 }.merge(valid_params)
      end

      it "updates daily report with correct params" do
        expect(daily_report).to have_received(:update)
      end

      it "sets success flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to index with see_other status" do
        expect(response).to redirect_to(user_daily_reports_path)
        expect(response.status).to eq(303)
      end
    end

    context "when update fails" do
      before do
        allow(daily_report).to receive(:update).and_return(false)
        patch :update, params: { id: 1 }.merge(valid_params)
      end

      it "attempts to update daily report" do
        expect(daily_report).to have_received(:update)
      end

      it "sets danger flash message" do
        expect(flash.now[:danger]).to be_present
      end

      it "renders edit template with unprocessable_entity status" do
        expect(response).to render_template(:edit)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      allow(DailyReport).to receive(:find).and_return(daily_report)
      allow(daily_report).to receive(:status_pending?)
      allow(daily_report).to receive(:destroy)
    end

    context "when daily report status is pending" do
      before do
        allow(daily_report).to receive(:status_pending?).and_return(true)
        delete :destroy, params: { id: 1 }
      end

      it "checks if status is pending" do
        expect(daily_report).to have_received(:status_pending?)
      end

      it "destroys the daily report" do
        expect(daily_report).to have_received(:destroy)
      end

      it "sets success flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to index with see_other status" do
        expect(response).to redirect_to(user_daily_reports_path)
        expect(response.status).to eq(303)
      end
    end

    context "when daily report status is not pending" do
      before do
        allow(daily_report).to receive(:status_pending?).and_return(false)
        delete :destroy, params: { id: 1 }
      end

      it "checks if status is pending" do
        expect(daily_report).to have_received(:status_pending?)
      end

      it "does not destroy the daily report" do
        expect(daily_report).not_to have_received(:destroy)
      end

      it "sets danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to index with see_other status" do
        expect(response).to redirect_to(user_daily_reports_path)
        expect(response.status).to eq(303)
      end
    end
  end

  describe "private methods" do
    describe "#belongs_department?" do
      context "when user has no department" do
        before do
          allow(DailyReport).to receive(:find).and_return(daily_report)
          allow(user).to receive(:department_id).and_return(nil)
          allow(controller).to receive(:belongs_department?).and_call_original
          get :show, params: { id: 1 }
        end

        it "sets danger flash message" do
          expect(flash[:danger]).to be_present
        end

        it "redirects to index" do
          expect(response).to redirect_to(user_daily_reports_path)
        end
      end
    end

    describe "#check_status" do
      context "when daily report status is read" do
        before do
          allow(DailyReport).to receive(:find).and_return(daily_report)
          allow(daily_report).to receive(:status_read?).and_return(true)
          allow(controller).to receive(:check_status).and_call_original
          get :edit, params: { id: 1 }
        end

        it "sets danger flash message" do
          expect(flash[:danger]).to be_present
        end

        it "redirects to index" do
          expect(response).to redirect_to(user_daily_reports_path)
        end
      end
    end
  end
end
