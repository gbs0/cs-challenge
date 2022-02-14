require 'pry'
require_relative '../modules/customer_success'

class CustomerSuccessBalancing
  include CustomerSuccess

  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
    @customer_success_ids = []

    validates!
  end
  
  def execute
    if minimum_available_customer_success? && maximum_allowed_customers?
      @customer_success = remaining_customer_success
      match_customer_with_customer_success
      serialize_customer_success_by_score
      balance_customer_success_by_winner
    end
  end

  private

  def balance_customer_success_by_winner
    # [{1 => 4}, {3 => 2}]
    return @customer_success_ids.keys.first if @customer_success_ids.size == 1
    # [4, 2]
    @customer_success_ids.values.uniq.size <= 1 ? 0 :  @customer_success_ids.keys.first
    # 1
  end

  def match_customer_with_customer_success
    @customer_success = @customer_success.sort_by { |key, _| key[:score] } if set_customer_success_hierarchy_by_score?
    @customers.map do |customer|
      customer_success = @customer_success.find { |customer_success| customer_success[:score] >= customer[:score] }
      @customer_success_ids << customer_success[:id] unless customer_success.nil?
    end
  end

  def serialize_customer_success_by_score
    @customer_success_ids = @customer_success_ids.sort.group_by(&:itself).transform_values(&:count).freeze
  end

  def remaining_customer_success
    @away_customer_success.empty? ? @customer_success : @customer_success.delete_if { |customer_success| @away_customer_success.include?(customer_success[:id])}
  end

  def maximum_allowed_customers?
    @customers.size < 1_000_000
  end

  def minimum_available_customer_success?
    (@customer_success.size / 2).floor.positive?
  end

  def set_customer_success_hierarchy_by_score?
    @customer_success.select {|customer_success| customer_success[:score].equal?(100)}.size.positive?
  end

  def validates!
    raise ArgumentError.new(message: "Invalid format for Customer Success #{@customer_success.first}") unless CustomerSuccess::Validations.of_customer_success?(@customer_success)
    raise ArgumentError.new(message: "Invalid format for Customer #{@customers.first}") unless CustomerSuccess::Validations.of_customers?(@customers)
    raise ArgumentError.new(message: "Customer Success ID must be between 0 and 1.000") unless CustomerSuccess::Validations.of_customer_success_id?(@customer_success)
    raise ArgumentError.new(message: "Customer Success Score must be between 0 and 10.000") unless CustomerSuccess::Validations.of_customer_success_score?(@customer_success)
  end
end