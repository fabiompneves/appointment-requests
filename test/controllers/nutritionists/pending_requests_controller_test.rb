require "test_helper"

class Nutritionists::PendingRequestsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @nutritionist = Nutritionist.create!(name: "Dra. Ana Silva", location: "Porto")
    @service = @nutritionist.services.create!(name: "Consulta Geral", price: 50)
  end

  test "should get index" do
    get nutritionists_pending_requests_path(nutritionist_id: @nutritionist.id)
    assert_response :success
  end

  test "should render React mount point" do
    get nutritionists_pending_requests_path(nutritionist_id: @nutritionist.id)
    assert_response :success

    # Check that page includes React mount point
    assert_select "div[id='pending-requests-root']"
  end

  test "should include nutritionist ID as data attribute" do
    get nutritionists_pending_requests_path(nutritionist_id: @nutritionist.id)
    assert_response :success

    # React component needs nutritionist ID
    assert_match /data-nutritionist-id="#{@nutritionist.id}"/, response.body
  end

  test "should accept any nutritionist_id parameter" do
    # Controller doesn't validate - React component handles API calls
    get nutritionists_pending_requests_path(nutritionist_id: 99999)

    assert_response :success
    assert_select "div[id='pending-requests-root']"
  end
end
