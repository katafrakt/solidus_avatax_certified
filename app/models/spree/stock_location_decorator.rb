ActiveSupport.on_load('Spree::StockLocation', run_once: true) do
  Spree::StockLocation.class_eval do
    include ToAvataxHash
  end
end
