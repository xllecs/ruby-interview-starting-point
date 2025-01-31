require_relative './app/services/coffee_shops_service'

class CoffeeShops < Thor
  LOCAL_CSV = 'data/coffee_shops.csv'

  desc 'closest_shops X Y', 'Finds the 3 closest coffee shops to the given user coordinates, in ascending order by distance'
  method_options url: :string, csv: :string
  def closest_shops(user_x, user_y)
    user_x = user_x.to_s
    user_y = user_y.to_s

    if user_x.match?(/[a-zA-Z]/) || user_y.match?(/[a-zA-Z]/)
      puts 'Arguments must be numbers. Please provide valid coordinates.'
      return
    end

    if !user_x.match?(/\A\-?\d+\.?\d+\z/) || !user_y.match?(/\A\-?\d+\.?\d+\z/)
      puts 'Invalid arguments. Please provide valid coordinates.'
      return
    end

    if user_x.to_f < -90 || user_x.to_f > 90 || user_y.to_f < -180 || user_y.to_f > 180
      puts 'Given coordinates exceed the valid ranges. Please provide valid coordinates.'
      return
    end

    source = options[:url] || options[:csv] || LOCAL_CSV
    service = CoffeeShopsService.new(user_x.to_f, user_y.to_f)
    shops = service.get_closest_coffee_shops(source)

    shops.each do |shop|
      p "#{shop[:name]},#{shop[:distance]}"
    end
  end
end
