require "rails_helper"

RSpec.describe ApplicationService do
  describe ".call" do
    it "forwards kwargs to new and calls #call" do
      service_class = Class.new(ApplicationService) do
        def initialize(x:, y:)
          @x = x
          @y = y
        end

        def call = @x + @y
      end

      expect(service_class.call(x: 2, y: 3)).to eq(5)
    end
  end
end
