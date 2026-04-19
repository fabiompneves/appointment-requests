require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  def setup
    @nutritionist = Nutritionist.create!(name: "Dra. Test", location: "Porto")
    @service = Service.new(
      nutritionist: @nutritionist,
      name: "Consulta Geral",
      price: 50.00
    )
  end

  test "should be valid with valid attributes" do
    assert @service.valid?
  end

  test "should require name" do
    @service.name = nil
    assert_not @service.valid?
    assert_includes @service.errors[:name], "can't be blank"
  end

  test "should require price" do
    @service.price = nil
    assert_not @service.valid?
    assert_includes @service.errors[:price], "can't be blank"
  end

  test "should require price to be greater than zero" do
    @service.price = 0
    assert_not @service.valid?
    assert_includes @service.errors[:price], "must be greater than 0"

    @service.price = -10
    assert_not @service.valid?
  end

  test "should belong to nutritionist" do
    assert_respond_to @service, :nutritionist
    assert_equal @nutritionist, @service.nutritionist
  end

  test "should have many appointment_requests" do
    assert_respond_to @service, :appointment_requests
  end
end
