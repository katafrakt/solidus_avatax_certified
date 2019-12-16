ActiveSupport.on_load('Spree::Shipment', run_once: true) do
  Spree::Shipment.class_eval do

    def avatax_cache_key
      key = ['Spree::Shipment']
      key << self.id
      key << self.cost
      key << self.stock_location.try(:cache_key)
      key << self.promo_total
      key.join('-')
    end

    def avatax_line_code
      'FR'
    end

    def avatax_digest
      id || object_id
    end

    def shipping_method_tax_code
      tax_code = shipping_method.tax_category.try(:tax_code)
      if tax_code.nil?
        ''
      else
        tax_code
      end
    end

    def tax_category
      selected_shipping_rate.try(:tax_rate).try(:tax_category) || shipping_method.try(:tax_category)
    end
  end
end
