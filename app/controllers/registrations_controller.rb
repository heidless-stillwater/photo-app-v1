class RegistrationsController < Devise::RegistrationsController
  def create

    ############
    # debug info
    puts "################### email: #{sign_up_params['email']}"
    puts "################### password: #{sign_up_params['password']}"
    puts "################### password_confirmation: #{sign_up_params['password_confirmation']}"
    ############

    build_resource(sign_up_params)
    resource.class.transaction do
      puts "####################### [1]"
      resource.save
      puts "####################### [2]"
      yield resource if block_given?
      puts "####################### [3]"
      if resource.persisted?
        puts "####################### [4]"
        @payment = Payment.new({ email: params["user"]["email"], 
          token: params[:payment]["token"], user_id: resource.id })
        flash[:error] = "Please check registration errors" unless @payment.valid?
        
        begin
          @payment.process_payment
          @payment.save
        rescue Exception => e
          flash[:error] = e.message
          resource.destroy
          puts 'Payment Failed'
          render :new and return
        end
        if resource.active_for_authentication?
          puts "####################### [5]"
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          puts "####################### [6]"
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        puts "####################### [7]"
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end        
    end
  end
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:payment)
  end
end