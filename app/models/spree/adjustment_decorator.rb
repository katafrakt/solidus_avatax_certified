ActiveSupport.on_load('Spree::Adjustment', run_once: true) do
  Spree::Adjustment.class_eval do
    def avatax_cache_key
      key = ['Spree::Adjustment']
      key << self.id
      key << self.amount
      key.join('-')
    end
  end
end
