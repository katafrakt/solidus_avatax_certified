require 'spec_helper'

describe Spree::Address, type: :model do
  let(:address) { build(:address) }

  describe '#validation_enabled?' do
    it 'returns true if preference is true and country validation is enabled' do
      Spree::Avatax::Config.address_validation = true
      Spree::Avatax::Config.address_validation_enabled_countries = ['United States', 'Canada']

      expect(address.validation_enabled?).to be_truthy
    end

    it 'returns false if address validation preference is false' do
      Spree::Avatax::Config.address_validation = false

      expect(address.validation_enabled?).to be_falsey
    end

    it 'returns false if enabled country is not present' do
      Spree::Avatax::Config.address_validation_enabled_countries = ['Canada']

      expect(address.validation_enabled?).to be_falsey
    end
  end

  describe '#country_validation_enabled?' do
    it 'returns true if the current country is enabled' do
      expect(address.country_validation_enabled?).to be_truthy
    end
  end

  describe '#validation_enabled_countries' do
    it 'returns an array' do
      expect(Spree::Address.validation_enabled_countries).to be_kind_of(Array)
    end

    it 'includes United States' do
      Spree::Avatax::Config.address_validation_enabled_countries = ['United States', 'Canada']

      expect(Spree::Address.validation_enabled_countries).to include('United States')
    end
  end

  describe '#avatax_cache_key' do
    subject { address.avatax_cache_key }

    context 'with a persisted record' do
      let(:address) { create(:address, zipcode: 10005) }

      it 'builds a cache key' do
        expect(subject).
          to eq("Spree::Address-#{address.id}-10005-Herndon-AL-US")
      end
    end

    context 'with a non-persisted record' do
      let(:address) { build(:address, zipcode: 10005) }

      it 'builds a cache key' do
        expect(subject).
          to eq("Spree::Address--10005-Herndon-AL-US")
      end
    end
  end
end
