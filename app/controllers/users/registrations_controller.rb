class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    build_resource(sign_up_params)

    if resource.save
      # Process payment
      if params[:payment].present? && (params[:payment][:payment_method_id].present? || params[:payment][:token].present?)
        @payment = resource.build_payment(
          payment_method_id: params[:payment][:payment_method_id],
          token: params[:payment][:token],
          email: resource.email
        )
        
        begin
          @payment.process_payment
          @payment.save!
        rescue Stripe::CardError => e
          resource.destroy
          flash[:error] = "Payment failed: #{e.message}"
          redirect_to new_user_registration_path and return
        rescue => e
          resource.destroy
          flash[:error] = "An error occurred while processing payment. Please try again."
          redirect_to new_user_registration_path and return
        end
      end

      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_up!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
  end
end
