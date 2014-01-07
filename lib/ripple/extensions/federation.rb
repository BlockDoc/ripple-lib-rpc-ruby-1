module Ripple
  class Federation
    def connection
      options = {
        headers: {'Accept' => "application/json; charset=utf-8"}
      }

      Faraday::Connection.new(options) do |connection|
        connection.use FaradayMiddleware::Mashify
        connection.request :json
        connection.response :json
        connection.use FaradayMiddleware::RaiseHttpException
        connection.adapter Faraday.default_adapter
      end
    end


    def service_declaration(domain)
      # Check 3 canonical locations
      urls = [
        "https://ripple.#{domain}/ripple.txt",
        "https://www.#{domain}/ripple.txt",
        "https://#{domain}/ripple.txt"
      ]

      response = nil
      urls.each do |url|
        begin
          response = Faraday.get url
          break
        rescue Faraday::Error::ConnectionFailed
          # raise ConnectionFailed
        rescue Faraday::Error::TimeoutError
          # raise Timedout
        end
      end

      bridge = nil
      if response
        lines = response.body.to_s.split("\n")
        lines.each_with_index do |line, index|
          if line == '[federation_url]' and lines.count > (index + 1)
            bridge = lines[index+1]
            break
          end
        end
      end

      bridge
    end

    # Parameters:
    #    url
    #    domain
    #    destination
    def service_request(params={})
      url = "#{params[:url]}?type=federation&destination=#{params[:destination]}&domain=#{params[:domain]}"
      # url = "#{params[:url]}?type=federation&domain=#{params[:domain]}&destination=#{params[:destination]}&user=#{params[:user]}"

      begin
        response = connection.get url
      rescue Faraday::Error::ConnectionFailed
        raise ConnectionFailed
      rescue Faraday::Error::TimeoutError
        raise Timedout
      end

      # Check for error
      if response.body.result == 'error'
        # Error
        raise FederationError, response.body.error_message
      end

      response.body.federation_json
    end

    # Parameters:
    #    url
    #    domain
    #    destination
    #    extra_fields
    #    amount
    #    currency
    # TODO: Change name to "bridge_transaction"
    def service_quote(params={})
      url = "#{params[:url]}?type=quote&amount=#{params[:amount]}%2F#{params[:currency]}&destination=#{params[:destination]}&domain=#{params[:domain]}}"

      # Add extra_fields to url
      if params.key?(:extra_fields)
        params[:extra_fields].each do |key, value|
          url = "#{url}&#{key}=#{value}"
        end
      end


      puts "URL: " + url

      begin
        response = connection.get url
      rescue Faraday::Error::ConnectionFailed
        raise ConnectionFailed
      rescue Faraday::Error::TimeoutError
        raise Timedout
      end

      # Check for error
      if response.body.result == 'error'
        # Error
        raise FederationError, response.body.error_message
      end
      if response.body.Result == "Error"
        raise FederationError, response.body.Message
      end

      quote = response.body.quote
      destination_amount = Ripple::Model::Amount.new(quote['send'].first)

      {
        destination_account: quote.address,
        destination_amount: destination_amount,
        destination_tag: quote.destination_tag,
        invoice_id: quote.invoice_id
      }
    end



    # Parameters:
    #    invoice_id
    #    url
    def invoice_verify(params={})
      url = "#{params[:url]}?type=invoice_id&iid=#{params[:invoice_id]}"

      begin
        response = connection.get url
      rescue Faraday::Error::ConnectionFailed
        raise ConnectionFailed
      rescue Faraday::Error::TimeoutError
        raise Timedout
      end

      # Check for error


      if response.body.result == "Success"
        # Success
        #puts response.body.to_json
        response.body.detail.success
      elsif response.body.result == 'Error'
        # Error
        raise FederationError, response.body.detail
      else
        # Unkonwn error
        puts response.inspect
        raise FederationError, "Unknown Error"
      end
    end
  end
end
