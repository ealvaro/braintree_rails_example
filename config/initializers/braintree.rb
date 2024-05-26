Dotenv.load

if !ENV["BT_ENVIRONMENT"] || !ENV["BT_MERCHANT_ID"] || !ENV["BT_PUBLIC_KEY"] || !ENV["BT_PRIVATE_KEY"]
  raise "Cannot find necessary environmental variables. See https://github.com/braintree/braintree_rails_example#setup-instructions for instructions";
end

Braintree::Configuration.environment = ENV["BT_ENVIRONMENT"].to_sym || :sandbox
Braintree::Configuration.environment = :production if Rails.env.production?
Braintree::Configuration.merchant_id = ENV['BT_MERCHANT_ID']
Braintree::Configuration.public_key = ENV['BT_PUBLIC_KEY']
Braintree::Configuration.private_key = ENV['BT_PRIVATE_KEY']