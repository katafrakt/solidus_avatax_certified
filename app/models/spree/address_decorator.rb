ActiveSupport.on_load('Spree::Address', run_once: true) do
  Spree::Address.class_eval do
    include ToAvataxHash

    def validation_enabled?
      Spree::Avatax::Config.address_validation && country_validation_enabled?
    end

    def country_validation_enabled?
      Spree::Address.validation_enabled_countries.include?(country.try(:name))
    end

    def self.validation_enabled_countries
      Spree::Avatax::Config.address_validation_enabled_countries
    end

    def avatax_cache_key
      key = ['Spree::Address']
      key << self.id
      key << self.zipcode
      key << self.city
      key << self.state&.abbr
      key << self.country.iso
      key.join('-')
    end
  end
end
