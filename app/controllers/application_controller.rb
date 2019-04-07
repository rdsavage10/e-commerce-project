class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :categories, :brands
  before_action :set_cart_count
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def categories
    @categories = Category.order(:name)
  end

  def brands
    @brands = Product.pluck(:brand).sort.uniq
  end

  def current_order
    if session[:order_id]
      return Order.find(session[:order_id])
    else
      return Order.new
    end
  end

  def set_cart_count
	  @cart_count = current_order.line_items.pluck(:quantity).sum or 0
	end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end
end
