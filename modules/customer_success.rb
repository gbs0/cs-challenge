module CustomerSuccess
  module Validations
    def self.of_customer_success?(customer_success)
      customer_success.map { |customer_success| customer_success.keys.include?(:id) }.all?
    end

    def self.of_customers?(customers)
      customers.map { |customer| customer.keys.include?(:id) }.all?
    end

    def self.of_customer_success_id?(customer_success)
      customer_success.sort { |customer_success| customer_success[:id] }.first[:id].positive? && customer_success.sort { |customer_success| customer_success[:id] }.first[:id] <= 1_000
    end

    def self.of_customer_success_score?(customer_success)
      customer_success.sort { |customer_success| customer_success[:score] }.first[:score].positive? && customer_success.sort { |customer_success| customer_success[:score] }.first[:score] <= 10_000
    end
  end
end