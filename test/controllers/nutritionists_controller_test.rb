require "test_helper"

class NutritionistsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @braga_nutritionist = Nutritionist.create!(name: "Dra. Ana Braga", location: "Braga")
    @braga_nutritionist.services.create!(name: "Nutrição Desportiva", price: 60)

    @porto_nutritionist = Nutritionist.create!(name: "Dr. João Porto", location: "Porto")
    @porto_nutritionist.services.create!(name: "Consulta Geral", price: 50)
  end

  test "should get index" do
    get nutritionists_path
    assert_response :success
  end

  test "should default to Braga when no location specified" do
    get nutritionists_path
    assert_response :success
    assert_select "strong", text: "Braga"
  end

  test "should search by nutritionist name" do
    get nutritionists_path, params: { query: "Ana", location: "Braga" }
    assert_response :success
    assert_match /Ana Braga/, response.body
  end

  test "should search by service name" do
    get nutritionists_path, params: { query: "Desportiva", location: "Braga" }
    assert_response :success
    assert_match /Ana Braga/, response.body
  end

  test "should filter by location" do
    get nutritionists_path, params: { query: "", location: "Porto" }
    assert_response :success
    assert_match /João Porto/, response.body
    assert_no_match /Ana Braga/, response.body
  end

  test "should handle empty search" do
    get nutritionists_path, params: { query: "", location: "Braga" }
    assert_response :success
    assert_match /Ana Braga/, response.body
  end

  test "should handle no results" do
    get nutritionists_path, params: { query: "NonexistentName", location: "Braga" }
    assert_response :success
    assert_match /Nenhum nutricionista encontrado/, response.body
  end
end
