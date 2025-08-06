class Payment < ApplicationRecord
  attr_accessor :card_number, :card_cvv, :card_expires_month, :card_expires_year, :token, :payment_method_id

  belongs_to :user

  def self.month_options
    Date::MONTHNAMES.compact.each_with_index.map { |name, i| ["#{i+1} - #{name}", i+1]}
  end

  def self.year_options
    (Date.today.year..(Date.today.year+10)).to_a
  end

  def process_payment
    # Use payment method ID if available (modern API), otherwise fall back to token
    if payment_method_id.present?
      process_with_payment_method
    elsif token.present?
      process_with_token
    else
      raise "No payment method or token provided"
    end
  end

  private

  def process_with_payment_method
    # Create customer and attach payment method
    customer = Stripe::Customer.create(
      email: user.email
    )

    # Attach payment method to customer
    Stripe::PaymentMethod.attach(
      payment_method_id,
      customer: customer.id
    )

    # Create payment intent
    Stripe::PaymentIntent.create(
      amount: 1000, # $10.00 in cents
      currency: 'usd',
      customer: customer.id,
      payment_method: payment_method_id,
      description: 'Premium Plan Subscription',
      confirm: true,
      automatic_payment_methods: {
        enabled: true,
        allow_redirects: 'never'
      }
    )
  end

  def process_with_token
    # Fallback to legacy token method
    customer = Stripe::Customer.create(
      email: user.email,
      source: token
    )

    Stripe::Charge.create(
      customer: customer.id,
      amount: 1000, # $10.00 in cents
      description: 'Premium Plan',
      currency: 'usd'
    )
  end
end
