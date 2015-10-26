require "spec_helper"

RSpec.describe "users API" do
  include Rack::Test::Methods

  def app
    Vmdb::Application
  end

  before { init_api_spec_env }

  context "with an appropriate role" do
    it "can change the user's password" do
      api_basic_authorize action_identifier(:users, :edit)

      expect do
        run_post users_url(@user.id), gen_request(:edit, :password => "new_password")
      end.to change { @user.reload.password_digest }

      expect_request_success
    end

    it "can change another user's password" do
      api_basic_authorize action_identifier(:users, :edit)
      user = FactoryGirl.create(:user)

      expect do
        run_post users_url(user.id), gen_request(:edit, :password => "new_password")
      end.to change { user.reload.password_digest }

      expect_request_success
    end
  end

  context "without an appropriate role" do
    it "can change the user's own password" do
      api_basic_authorize

      expect do
        run_post users_url(@user.id), gen_request(:edit, :password => "new_password")
      end.to change { @user.reload.password_digest }

      expect_request_success
    end

    it "will not allow the changing of attributes other than the password" do
      api_basic_authorize

      expect do
        run_post users_url(@user.id), gen_request(:edit, :email => "new.email@example.com")
      end.not_to change { @user.reload.email }

      expect_bad_request
    end

    it "cannot change another user's password" do
      api_basic_authorize
      user = FactoryGirl.create(:user)

      expect do
        run_post users_url(user.id), gen_request(:edit, :password => "new_password")
      end.not_to change { user.reload.password_digest }

      expect_request_forbidden
    end
  end
end
