require_relative '../../app/services/coffee_shops_service'

RSpec.describe CoffeeShopsService do
  subject(:service) { described_class.new(47.6, -122.4) }

  let(:url) { 'https://example.com/coffee_shops.csv' }
  let(:file) { 'data/coffee_shops.csv' }

  describe '#get_closest_coffee_shops' do
    let(:csv_data) do
      <<~CSV
        Starbucks Seattle,47.5809,-122.3160
        Starbucks SF,37.5209,-122.3340
        Starbucks Moscow,55.752047,37.595242
        Starbucks Seattle2,47.5869,-122.3368
        Starbucks Rio De Janeiro,-22.923489,-43.234418
        Starbucks Sydney,-33.871843,151.206767
      CSV
    end

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: csv_data)
    end

    it 'correctly outputs the 3 closest coffee shops to the user\'s coordinated in ascending order by distance' do
      shops = service.get_closest_coffee_shops(url)
      expected_result = [
        { name: "Starbucks Seattle2", x: 47.5869, y: -122.3368, distance: 0.0645 },
        { name: "Starbucks Seattle", x: 47.5809, y: -122.316, distance: 0.0861 },
        { name: "Starbucks SF", x: 37.5209, y: -122.334, distance: 10.0793 }
      ]

      expect(shops.length).to eq(3)
      expect(shops.first).to have_key(:distance)
      expect(shops).to eq(expected_result)
    end

    context 'when there are less than 3 coffee shops in the provided URL' do
      let(:csv_data) do
        <<~CSV
          Starbucks Moscow,55.752047,37.595242
        CSV
      end

      it 'processes the available coffee shops' do
        shops = service.get_closest_coffee_shops(url)

        expect(shops.length).to eq(1)
        expect(shops.first).to eq({ name: "Starbucks Moscow", x: 55.752047, y: 37.595242, distance: 160.2028 })
      end
    end
  end

  describe '#get_coffee_shops_from_url' do
    context 'when provided URL is valid' do
      before do
        stub_request(:get, url)
          .to_return(status: 200, body: csv_data)
      end

      context 'when provided URL has coffee shops' do
        context 'when data is valid' do
          let(:csv_data) do
            <<~CSV
              Starbucks Seattle,47.5809,-122.3160
              Starbucks SF,37.5209,-122.3340
              Starbucks Moscow,55.752047,37.595242
              Starbucks Seattle2,47.5869,-122.3368
              Starbucks Rio De Janeiro,-22.923489,-43.234418
              Starbucks Sydney,-33.871843,151.206767
            CSV
          end

          it 'fetches and parses the CSV data correctly' do
            expected_result = [
              { name: "Starbucks Seattle", x: 47.5809, y: -122.316 },
              { name: "Starbucks SF", x: 37.5209, y: -122.334 },
              { name: "Starbucks Moscow", x: 55.752047, y: 37.595242 },
              { name: "Starbucks Seattle2", x: 47.5869, y: -122.3368 },
              { name: "Starbucks Rio De Janeiro", x: -22.923489, y: -43.234418 },
              { name: "Starbucks Sydney", x: -33.871843, y: 151.206767 }
            ]
            expect(service.send(:get_coffee_shops_from_url, url)).to eq(expected_result)
          end
        end

        context 'when data is invalid' do
          context 'when one of the coordinates is missing' do
            let(:csv_data) do
              <<~CSV
                Starbucks Seattle,47.5809,-122.3160
                Starbucks SF,37.5209
              CSV
            end

            it 'raises an error' do
              expect { service.send(:get_coffee_shops_from_url, url) }.to raise_error(ArgumentError, "Malformed shop data: [\"Starbucks SF\", \"37.5209\"]")
            end
          end

          context 'when one of the coordinates is invalid' do
            let(:csv_data) do
              <<~CSV
                Starbucks Seattle,47.5809,-122.3160
                Starbucks SF,37.5209,21invalid-
              CSV
            end

            it 'raises an error' do
              expect { service.send(:get_coffee_shops_from_url, url) }.to raise_error(ArgumentError, "Malformed shop data: [\"Starbucks SF\", \"37.5209\", \"21invalid-\"]")
            end
          end

          context 'when coffee shop is invalid' do
            let(:csv_data) do
              <<~CSV
                Starbucks Seattle,47.5809,-122.3160
                Starinvalid- SF,37.5209,-122.334
              CSV
            end

            it 'raises an error' do
              expect { service.send(:get_coffee_shops_from_url, url) }.to raise_error(ArgumentError, "Malformed shop data: [\"Starinvalid- SF\", \"37.5209\", \"-122.334\"]")
            end
          end
        end
      end

      context 'when provided URL has no coffee shops' do
        let(:csv_data) { '' }

        it 'returns an empty array' do
          expect(service.send(:get_coffee_shops_from_url, url)).to eq([])
        end
      end
    end


    context 'when provided URL is broken' do
      before { stub_request(:get, url).and_return(status: 404, body: '"404: Not Found"') }

      it 'returns an empty array' do
        expect { service.send(:get_coffee_shops_from_url, url) }.to raise_error(ArgumentError, "Malformed shop data: [\"404: Not Found\"]")
      end
    end
  end

  describe '#get_coffee_shops_from_file' do
    context 'when the file exists' do
      it 'it parses and returns the CSV data correctly' do
        expected_result = [
          { name: "Starbucks Seattle", x: 47.5809, y: -122.316 },
          { name: "Starbucks SF", x: 37.5209, y: -122.334 },
          { name: "Starbucks Moscow", x: 55.752047, y: 37.595242 },
          { name: "Starbucks Seattle2", x: 47.5869, y: -122.3368 },
          { name: "Starbucks Rio De Janeiro", x: -22.923489, y: -43.234418 },
          { name: "Starbucks Sydney", x: -33.871843, y: 151.206767 }
        ]
        expect(service.send(:get_coffee_shops_from_file, file)).to eq(expected_result)
      end
    end
  end

  describe '#calculate_distance' do
    context 'when coordinates are different' do
      let(:shop) { { name: "Starbucks Seattle", x: 47.5809, y: -122.316 } }

      it 'calculates the distance between the user and a shop' do
        expect(service.send(:calculate_distance, shop)).to eq(0.0861)
      end
    end

    context 'when coordinates are identical' do
      let(:shop) { { name: 'Starbucks Seattle', x: 47.6, y: -122.4 } }

      it 'returns zero' do
        expect(service.send(:calculate_distance, shop)).to eq(0.0)
      end
    end
  end
end
