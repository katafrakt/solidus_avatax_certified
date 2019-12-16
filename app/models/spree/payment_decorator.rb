ActiveSupport.on_load('Spree::Payment', run_once: true) do
  Spree::Payment.class_eval do
    self.state_machine.after_transition to: :completed, do: :avalara_finalize
    self.state_machine.after_transition to: :void, do: :cancel_avalara

    delegate :avalara_tax_enabled?, to: :order

    def cancel_avalara
      order.avalara_transaction.cancel_order unless order.avalara_transaction.nil?
    end

    def avalara_finalize
      return unless avalara_tax_enabled?

      order.avalara_capture_finalize
    end
  end
end
