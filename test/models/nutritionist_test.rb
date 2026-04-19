require "test_helper"

class NutritionistTest < ActiveSupport::TestCase
  def setup
    @nutritionist = Nutritionist.new(
      name: "Dra. Test Silva",
      location: "Porto"
    )
  end

  test "should be valid with valid attributes" do
    assert @nutritionist.valid?
  end

  test "should require name" do
    @nutritionist.name = nil
    assert_not @nutritionist.valid?
    assert_includes @nutritionist.errors[:name], "can't be blank"
  end

  test "should require location" do
    @nutritionist.location = nil
    assert_not @nutritionist.valid?
    assert_includes @nutritionist.errors[:location], "can't be blank"
  end

  test "should have many services" do
    assert_respond_to @nutritionist, :services
  end

  test "should have many appointment_requests" do
    assert_respond_to @nutritionist, :appointment_requests
  end

  test "should search by nutritionist name" do
    nutritionist = Nutritionist.create!(name: "Dr. João Santos", location: "Braga")
    service = nutritionist.services.create!(name: "Consulta Geral", price: 50)

    results = Nutritionist.search("João", "Braga")
    assert_includes results, nutritionist
  end

  test "should search by service name" do
    nutritionist = Nutritionist.create!(name: "Dr. João Santos", location: "Braga")
    service = nutritionist.services.create!(name: "Nutrição Desportiva", price: 60)

    results = Nutritionist.search("Desportiva", "Braga")
    assert_includes results, nutritionist
  end

  test "should filter by location in search" do
    braga_nutritionist = Nutritionist.create!(name: "Dr. Braga", location: "Braga")
    braga_nutritionist.services.create!(name: "Consulta", price: 50)
    
    porto_nutritionist = Nutritionist.create!(name: "Dr. Porto", location: "Porto")
    porto_nutritionist.services.create!(name: "Consulta", price: 50)

    results = Nutritionist.search("Consulta", "Braga")
    assert_includes results, braga_nutritionist
    assert_not_includes results, porto_nutritionist
  end

  test "should be case insensitive in search" do
    nutritionist = Nutritionist.create!(name: "Dr. João Santos", location: "Braga")
    service = nutritionist.services.create!(name: "Consulta Geral", price: 50)

    results = Nutritionist.search("joão", "braga")
    assert_includes results, nutritionist
  end
end
