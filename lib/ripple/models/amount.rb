module Ripple
  module Model
    class Amount
      attr_accessor :currency
      attr_accessor :issuer
      attr_accessor :value

      def initialize(amount_json)
        # puts amount_json.inspect
        if amount_json.key?('currency') or not amount_json[:currency].nil?
          # IOU
          self.currency = amount_json[:currency] || amount_json.currency
          self.issuer = amount_json[:issuer] || amount_json.issuer
          self.value = amount_json[:value] || amount_json.value
        else
          # XRP
          self.currency = 'XRP'
          self.issuer = ''
          self.value = amount_json
        end
      end

      def is_xrp?
        self.currency == 'XRP'
      end

      def to_json(options = {})
        if is_xrp?
          self.value
        else
          {currency: self.currency, issuer: self.issuer, value: self.value}
        end
      end
    end
  end
end
