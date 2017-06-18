class TransactionBasketsController < ApplicationController

  respond_to :json

  def create
    @transaction_basket = TransactionBasket.new({basket_name: params[:basket_name], transaction_id: params[:transaction_id], identification_rule: '200%'})
    @transaction = TransactionPurchase.find(params[:transaction_id])
    @transaction_main = @transaction.main
    
    begin
      @transaction_basket.save
      params[:property_ids].each do |property_id|
        @transaction_basket.transaction_basket_properties.create(:property_id => property_id)
        if @transaction.transaction_properties.where(property_id: property_id).count == 0
          @transaction.transaction_properties.create({
            property_id: property_id,
            transaction_id: @transaction.id,
            is_sale: false,
            sale_price: Property.find(property_id).price,
            cap_rate: Property.find(property_id).cap_rate,
            transaction_main_id: @transaction.main.id,
            is_selected: true
          })
        end
      end

      params[:type] = 'purchase'
      params[:main_id] = @transaction_main.id
      render json: {
        status: true,
        basket: @transaction_basket,
        content: (render_to_string partial: '/layouts/left_sidebar', layout: false )
      }
    
    rescue Exception => e
      render json: {status: false, error: e.message}
    end
  end

  def destroy
    @transaction_basket = TransactionBasket.find(params[:id])
    
    if @transaction_basket.destroy
      render json: true
    else
      render json: false
    end
    
  end

  def update
    @transaction_basket = TransactionBasket.find(params[:id])
    if @transaction_basket.transaction_basket_properties.destroy_all
      params[:property_ids].each do |property_id|
        @transaction_basket.transaction_basket_properties.create(:property_id => property_id)
      end
      render json: { status: true, basket: @transaction_basket }
    else
      render json: { status: false }
    end
  end

  #Custom Action
  def identify_basket_to_qi
    basket = TransactionBasket.find(params[:id])
    basket_properties = basket.transaction_basket_properties
    @transaction = TransactionPurchase.find(params[:transaction_id])
    @transaction_main = @transaction.main

    begin
      basket_properties.each do |basket_property|
        @transaction.transaction_properties.where.not(property_id: basket_property.property_id).destroy_all
      end
      basket.update(is_identified_to_qi: true)

      params[:type] = 'purchase'
      params[:main_id] = @transaction_main.id
      render json: {
        status: true,
        content: (render_to_string partial: '/layouts/left_sidebar', layout: false )
      }
    rescue Exception => e
      render json: {status: false, error: e.message}
    end

  end

end
