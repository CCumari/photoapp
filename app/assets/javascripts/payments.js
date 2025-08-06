// Stripe configuration
document.addEventListener('DOMContentLoaded', function() {
  const paymentForm = document.getElementById('payment-form');
  
  if (paymentForm) {
    // Get the publishable key from the meta tag
    const publishableKey = document.querySelector('meta[name="stripe-publishable-key"]')?.getAttribute('content');
    
    if (!publishableKey) {
      console.error('Stripe publishable key not found. Please check your configuration.');
      return;
    }
    
    const stripe = Stripe(publishableKey);
    
    // Form submission handler
    paymentForm.addEventListener('submit', function(event) {
      event.preventDefault();
      
      const form = event.target;
      const submitButton = document.getElementById('submit-payment');
      const errorElement = document.getElementById('card-errors');
      
      // Disable submit button
      submitButton.disabled = true;
      submitButton.textContent = 'Processing...';
      
      // Clear previous errors
      errorElement.classList.add('d-none');
      errorElement.textContent = '';
      
      // Get card data
      const cardData = {
        number: form.querySelector('[data-stripe="number"]').value,
        cvc: form.querySelector('[data-stripe="cvv"]').value,
        exp_month: form.querySelector('[data-stripe="exp-month"]').value,
        exp_year: form.querySelector('[data-stripe="exp-year"]').value
      };
      
      // Validate card data
      if (!cardData.number || !cardData.cvc || !cardData.exp_month || !cardData.exp_year) {
        errorElement.textContent = 'Please fill in all card fields.';
        errorElement.classList.remove('d-none');
        submitButton.disabled = false;
        submitButton.textContent = 'Create Account';
        return;
      }
      
      // Create token using the updated API
      stripe.createToken({
        type: 'card',
        card: {
          number: cardData.number,
          cvc: cardData.cvc,
          exp_month: cardData.exp_month,
          exp_year: cardData.exp_year
        }
      }).then(function(result) {
        if (result.error) {
          // Show error
          errorElement.textContent = result.error.message;
          errorElement.classList.remove('d-none');
          
          // Re-enable submit button
          submitButton.disabled = false;
          submitButton.textContent = 'Create Account';
        } else {
          // Add token to form and submit
          const tokenInput = document.createElement('input');
          tokenInput.type = 'hidden';
          tokenInput.name = 'payment[token]';
          tokenInput.value = result.token.id;
          form.appendChild(tokenInput);
          
          // Clear sensitive data
          form.querySelector('[data-stripe="number"]').value = '';
          form.querySelector('[data-stripe="cvv"]').value = '';
          
          // Submit form
          form.submit();
        }
      });
    });
  }
});
