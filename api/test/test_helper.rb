ENV["RAILS_ENV"] ||= "test"
# テストでは、管理用の合言葉を決まった値にする
ENV["ADMIN_API_TOKEN"] = "test-admin-token"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # 管理用 API を呼ぶときのヘッダー
    def admin_headers(token = "test-admin-token")
      { "Authorization" => "Bearer #{token}" }
    end
  end
end
