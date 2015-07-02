class Lead
  include HTTParty
  format :json
  base_uri 'app.close.io:443'
  basic_auth ENV['CLOSEIO_API_KEY'], ''
end
