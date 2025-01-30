require "httparty"
require "csv"

class CoffeeShopsService
  def initialize(user_x, user_y)
    @user_x = user_x
    @user_y = user_y
  end

  def get_closest_coffee_shops(url)
    shops = url ? get_coffee_shops_from_url : get_coffee_shops_from_file
    shops.map do |shop|
      distance = calculate_distance(shop)
      shop[:distance] = distance
      shop
    end.sort_by { |shop| shop[:distance] }.first(3)
  end

  private

  def get_coffee_shops_from_file
    parse_coffee_shops(CSV.read("data/coffee_shops.csv"))
  end

  def get_coffee_shops_from_url
    response = HTTParty.get(ENV["CSV_DATA"])

    return [] if response.body == ""

    parse_coffee_shops(CSV.parse(response.body))
  end

  def parse_coffee_shops(data)
    data.map do |row|
      raise ArgumentError, "Malformed shop data: #{row.inspect}" if !is_valid_row?(row)

      { name: row[0], x: row[1].to_f, y: row[2].to_f }
    end
  end

  def is_valid_row?(row)
    row.length == 3 && is_valid_name?(row[0]) && is_valid_coordinate?(row[1]) && is_valid_coordinate?(row[2])
  end

  def is_valid_name?(value)
    return false if value.nil? || value.strip.empty? || !value.strip.match?(/\A[Ss]tarbucks[\w\s]+\z/)
    true
  end

  def is_valid_coordinate?(value)
    return false if value.nil? || value.strip.empty? || !value.match?(/\A^\-?\d+\.?\d+\z/)
    true
  end

  def calculate_distance(shop)
    Math.sqrt((shop[:x] - @user_x) ** 2 + (shop[:y] - @user_y) ** 2).round(4)
  end
end
