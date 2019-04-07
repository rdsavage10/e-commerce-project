class CartController < ApplicationController

  before_action :authenticate_user!, except: [:add_to_cart, :view_order, :clear_line_item, :clear_cart]

  def add_to_cart
    @order = current_order
    # if @order.line_items.exists?
      # line_item = @order.line_items.update(quantity: params[:quantity]
      # @order.save
    # else
      line_item = @order.line_items.new(quantity: params[:quantity], product_id: params[:product_id])
      @order.save
    # end
      session[:order_id] = @order.id

      line_item.update(line_item_total: (line_item.quantity * line_item.product.price))

      redirect_back(fallback_location: root_path)
  end

  def view_order
    @line_items = current_order.line_items
  end

  def checkout
    @line_items = current_order.line_items

    if(@line_items.length > 0)
      @order = Order.create(user_id: current_user.id, subtotal: 0)

      @line_items.each do |line_item|
          line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
          @order.order_items[line_item.product_id] = line_item.quantity
          @order.subtotal += line_item.line_item_total
        end
      @order.save

      @order.update(sales_tax: (@order.subtotal * 0.07))
      @order.update(grand_total: (@order.sales_tax + @order.subtotal))

      @line_items.destroy_all
    end
  end

  def clear_cart
    LineItem.destroy_all
    redirect_back(fallback_location: root_path)
  end

  def clear_line_item
    current_order.order_items.find_by(product_id: params[:product_id]).delete
  end
end
