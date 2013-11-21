#require 'ripple'
require './lib/ripple'


ripple = Ripple.client({
  endpoint: "http://s1.ripple.com:51234/",
  client_account: "r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj",
  client_secret: "ssm5HPoeEZYJWvkJvQW9ro6e6hW9m"
})

# Send and verify with error checking
# success = false
# begin
#     failed = false
#     begin
#         puts "Sending transaction"
#         tx_hash = ripple.send_currency("rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc", "USD", "0.0001")
#         success = true
#     rescue Ripple::SubmitFailed
#         # Handle failed submit
#         puts "Transaction failed"
#         failed = true
#     rescue Ripple::ServerUnavailable
#         puts "Server Unavailable"
#     end
# end while not success and not failed
# if success
#     # Verify transaction
#     complete = false
#     begin
#       begin
#         puts "Checking transaction status"
#         complete = ripple.transaction_suceeded?(tx_hash)
#       rescue Ripple::InvalidTxHash
#         puts "Invalid Tx Hash"
#       rescue Ripple::ServerUnavailable
#         puts "Server Unavailable"
#       end
#       if not complete
#         # Sleep for small amount of time before checking again
#         sleep 1
#       end
#     end while not complete
#     puts "Transaction complete"
# end

# Verify Transaction
# begin
#     if ripple.transaction_suceeded?("84062717735DD0E6255F3A64750F543020D7DA05AA344012EFF1FEFB8213F735")
#         puts "Transaction complete"
#     else
#         puts "Transaction Pending"
#     end
# rescue Ripple::InvalidTxHash
#     puts "Invalid transaction"
# end


# Send complex IOU
# 1. Find path
success = false
begin
    begin
        puts "Finding Path"
        params = {
          destination_account: "r9cZA1mLK5R5Am25ArfXFmqgNwjZgnfk59",
          destination_issuer: "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B",
          destination_amount: "0.0001",
          destination_currency: "EUR",
          source_account: "r9cZA1mLK5R5Am25ArfXFmqgNwjZgnfk59",
          source_currency: "USD"
        }
        path = ripple.find_first_available_path(params)
        #puts path.inspect
        puts path.source_amount.inspect
        success = true
    rescue Ripple::ServerUnavailable
        puts "Server Unavailable"
    end
end while not success
# 2. Submit transaction
success = false
failed = false
begin
  begin
      puts "Submitting transaction"
      # params = {
      #   destination_account: "r9cZA1mLK5R5Am25ArfXFmqgNwjZgnfk59",
      #   destination_issuer: "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B",
      #   destination_amount: "0.0001",
      #   destination_currency: "EUR",
      #   source_account: "r9cZA1mLK5R5Am25ArfXFmqgNwjZgnfk59",
      #   source_currency: "USD"
      # }
      tx_hash = ripple.send_other_currency(destination="r9cZA1mLK5R5Am25ArfXFmqgNwjZgnfk59" , source_currency="USD", destination_currency="EUR", path=path, amount="0.0001")
      success = true
  rescue Ripple::SubmitFailed
    puts "Transaction Failed"
    failed = true
  rescue Ripple::ServerUnavailable
      puts "Server Unavailable"
  end
end while not success and not failed
# # 3. Verify transaction
# if success

#     complete = false
#     begin
#       begin
#         puts "Checking transaction status"
#         complete = ripple.transaction_suceeded?(tx_hash)
#       rescue Ripple::InvalidTxHash
#         puts "Invalid Tx Hash"
#       rescue Ripple::ServerUnavailable
#         puts "Server Unavailable"
#       end
#       if not complete
#         # Sleep for small amount of time before checking again
#         sleep 1
#       end
#     end while not complete
#     puts "Transaction complete"
# end





