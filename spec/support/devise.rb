RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request

  config.before(type: :controller) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
end
