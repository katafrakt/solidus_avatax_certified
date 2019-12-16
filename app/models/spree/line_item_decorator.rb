ActiveSupport.on_load('Spree::LineItem', run_once: true) do
  Spree::LineItem.class_eval do
    def to_hash
      {
        'Index' => id,
        'Name' => name,
        'ItemID' => sku,
        'Price' => price.to_s,
        'Qty' => quantity,
        'TaxCategory' => tax_category
      }
    end

    def avatax_cache_key
      key = ['Spree::LineItem']
      key << self.avatax_digest
      key << self.quantity
      key << self.price
      key << self.promo_total
      key.join('-')
    end

    def avatax_line_code
      'LI'
    end

    def avatax_digest
      id || variant.sku
    end
  end
end
