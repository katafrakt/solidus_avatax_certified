ActiveSupport.on_load('Spree::User', run_once: true) do
  Spree::User.class_eval do
    puts 'DECORATING SPREE JUSER'
    belongs_to :avalara_entity_use_code
  end
end
