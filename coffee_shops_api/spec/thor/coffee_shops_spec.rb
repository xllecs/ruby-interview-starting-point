load File.expand_path('../../coffee_shops.thor', __dir__)
require_relative '../../app/services/coffee_shops_service'

RSpec.describe CoffeeShops do
  subject(:coffee_shops_cli) { described_class.new }

  describe '#closest_shops' do
    context 'when the user provides valid coordinates' do
      let(:user_x) { '47.6' }
      let(:user_y) { '-122.4' }
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
        stub_request(:get, ENV['CSV_DATA'])
          .and_return(status: 200, body: csv_data)
      end

      it 'sends correct parameters to CoffeeShopsService' do
        expect(CoffeeShopsService).to receive(:new).with(47.6, -122.4).and_call_original

        coffee_shops_cli.closest_shops('47.6', '-122.4')
      end

      it 'outputs the 3 closest coffee shops to the user' do
        expected_output = "\"Starbucks Seattle2,0.0645\"\n\"Starbucks Seattle,0.0861\"\n\"Starbucks SF,10.0793\"\n"

        expect { coffee_shops_cli.closest_shops(user_x, user_y) }.to output(expected_output).to_stdout
      end
    end

    context 'when the user provides invalid coordinates' do
      context 'when the user provides non-numeric coordinates' do
        let(:user_x) { '47.6' }
        let(:user_y) { 'invalid' }

        it 'outputs an error message and returns' do
          expect { coffee_shops_cli.closest_shops(user_x, user_y) }.to output("Arguments must be numbers. Please provide valid coordinates.\n").to_stdout
        end
      end

      context 'when coordinates exceed the valid ranges' do
        let(:user_x) { '47.6' }
        let(:user_y) { '181' }

        it 'outputs an error message and returns' do
          expect { coffee_shops_cli.closest_shops(user_x, user_y) }.to output("Given coordinates exceed the valid ranges. Please provide valid coordinates.\n").to_stdout
        end
      end
    end
  end
end
