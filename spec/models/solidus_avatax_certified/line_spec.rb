require 'spec_helper'

describe SolidusAvataxCertified::Line, :vcr do
  context 'with a persisted order' do
    let(:order) { create(:avalara_order, line_items_count: 2) }
    let(:sales_lines) { SolidusAvataxCertified::Line.new(order, 'SalesOrder') }

    before do
      VCR.use_cassette("order_capture", allow_playback_repeats: true) do
        order
      end
    end

    describe '#initialize' do
      it 'should have order' do
        expect(sales_lines.order).to eq(order)
      end
      it 'should have lines be an array' do
        expect(sales_lines.lines).to be_kind_of(Array)
      end
      it 'lines should be a length of 3' do
        expect(sales_lines.lines.length).to eq(3)
      end
    end

    context 'sales order' do
      describe '#build_lines' do
        it 'receives method item_lines_array' do
          expect(sales_lines).to receive(:item_lines_array)
          sales_lines.build_lines
        end
        it 'receives method shipment_lines_array' do
          expect(sales_lines).to receive(:shipment_lines_array)
          sales_lines.build_lines
        end
      end

      describe '#item_lines_array' do
        it 'returns an Array' do
          expect(sales_lines.item_lines_array).to be_kind_of(Array)
        end
      end

      describe '#shipment_lines_array' do
        it 'returns an Array' do
          expect(sales_lines.shipment_lines_array).to be_kind_of(Array)
        end
        it 'should have a length of 1' do
          expect(sales_lines.shipment_lines_array.length).to eq(1)
        end
      end

      describe '#item_line' do
        it 'returns a Hash with correct keys' do
          expect(sales_lines.item_line(order.line_items.first)).to be_kind_of(Hash)
          expect(sales_lines.item_line(order.line_items.first)[:number]).to be_present
        end
      end
      describe '#shipment_line' do
        it 'returns a Hash with correct keys' do
          expect(sales_lines.shipment_line(order.shipments.first)).to be_kind_of(Hash)
          expect(sales_lines.shipment_line(order.shipments.first)[:number]).to be_present
        end
      end
    end

    context 'return invoice' do
      let(:authorization) { generate(:refund_transaction_id) }
      let(:payment_amount) { 10*2 }
      let(:payment_method) { build(:credit_card_payment_method) }
      let(:payment) { build(:payment, amount: payment_amount, payment_method: payment_method, order: order) }
      let(:refund_reason) { build(:refund_reason) }
      let(:gateway_response) {
        ActiveMerchant::Billing::Response.new(
          gateway_response_success,
          gateway_response_message,
          gateway_response_params,
          gateway_response_options
        )
      }
      let(:gateway_response_success) { true }
      let(:gateway_response_message) { '' }
      let(:gateway_response_params) { {} }
      let(:gateway_response_options) { {} }

      let(:refund) {Spree::Refund.new(payment: payment, amount: BigDecimal.new(10), reason: refund_reason, transaction_id: nil)}
      let(:shipped_order) { build(:shipped_order) }
      let(:return_lines) { SolidusAvataxCertified::Line.new(shipped_order, 'ReturnOrder', refund) }

      describe 'build_lines' do
        it 'receives method refund_lines' do
          expect(return_lines).to receive(:refund_lines)
          return_lines.build_lines
        end
      end
      describe '#refund_line' do
        it 'returns an Hash' do
          expect(return_lines.refund_line).to be_kind_of(Hash)
        end
      end
      describe '#refund_line' do
        it 'returns an Array' do
          expect(return_lines.refund_lines).to be_kind_of(Array)
        end
      end
    end
  end

  context 'with a non-persisted order' do
    let(:stock_location) { create(:stock_location) }
    let(:store) { create(:store) }
    let(:address) { build(:address) }
    let(:product) { Spree::Product.create(name: 'default') }
    let(:tax_category) { create(:tax_category) }
    let(:shipping_method) { create(:shipping_method) }
    let(:tax_rate) { create(:tax_rate) }
    let(:shipping_rate) { Spree::ShippingRate.new(selected: true, shipping_method: shipping_method, tax_rate_id: tax_rate.id) }
    let(:stock_location) { create(:stock_location) }
    let(:shipment) { Spree::Shipment.new(shipping_rates: [shipping_rate], stock_location: stock_location) }
    let(:variant) { Spree::Variant.new(product: product, tax_category: tax_category) }

    let(:line_item) { Spree::LineItem.new(variant: variant, price: 1, quantity: 1) }
    let(:line_items) { [ line_item ] }
    let(:order) { Spree::Order.new(line_items: line_items, store: store, ship_address: address, shipments: [shipment]) }
    let(:sales_lines) { SolidusAvataxCertified::Line.new(order, 'SalesOrder') }

    it 'uses the line_item object_id in the line_item number' do
      expect(sales_lines.item_line(order.line_items.first)).to be_kind_of(Hash)
      expect(sales_lines.item_line(order.line_items.first)[:number]).to be_present
      expect(sales_lines.item_line(order.line_items.first)[:number]).to include variant.sku
    end

    it 'uses the shipment object_id in the shipment number' do
      expect(sales_lines.shipment_line(order.shipments.first)).to be_kind_of(Hash)
      expect(sales_lines.shipment_line(order.shipments.first)[:number]).to be_present
      expect(sales_lines.shipment_line(order.shipments.first)[:number]).to include shipment.object_id.to_s
    end
  end
end
