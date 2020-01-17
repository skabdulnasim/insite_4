module StocksHelper

  def get_stock_update_chart_data(_product_id,_store_id)
    stock_updates = StockUpdate.by_product(_product_id).by_store(_store_id).last_week
    chart_data = {}
    stock_updates.each do |sup|
      chart_data[sup.created_at] = sup.stock
    end
    return chart_data
  end

  def get_stock_credit_pie_data(_product_id,_store_id)
    _stocks = Stock.get_product(_product_id).set_store(_store_id).type_credit.last_week
    _stocks = _stocks.select("stock_transaction_type, sum(stock_credit) as total_debit").group("stock_transaction_type")
    pie_data = {}
    _stocks.each do |sup|
      pie_data[sup.stock_transaction_type] = sup.total_debit
    end
    return pie_data
  end

  def get_stock_debit_pie_data(_product_id,_store_id)
    _stocks = Stock.get_product(_product_id).set_store(_store_id).type_debit.last_week
    _stocks = _stocks.select("stock_transaction_type, sum(stock_debit) as total_debit").group("stock_transaction_type")
    pie_data = {}
    _stocks.each do |sup|
      pie_data[sup.stock_transaction_type] = sup.total_debit
    end
    return pie_data
  end

  def get_product_todays_debit(store, product)
    _t_debit = Stock.get_product(product).set_store(store).type_debit.last_day
    return _t_debit.sum(:stock_debit)
  end

  def get_product_todays_credit(store, product) 
    _t_credit = Stock.get_product(product).set_store(store).type_credit.last_day
    return _t_credit.sum(:stock_credit)
  end

  def get_kitchen_consumption_pie_data(product,store)
    _raws = StockProductionRaw.set_store(store).set_product(product).last_week.select("target_product_id, sum(quantity) as total_qty").group("target_product_id")
    pie_data = {}
    _raws.each do |raw|
      pie_data[raw.target_product.name] = raw.total_qty
    end
    return pie_data
  end

  def get_product_avg_production_price(store_id, product_id)
    _price = StockProductionMeta.set_store(store_id).set_product(product_id).pluck('sum(price) / sum(production_quantity)').first
    return _price
  end

  def stock_purchase_total_price(stock_purchase_id)
    @stock_purchase = StockPurchase.find(stock_purchase_id)
    _cancelled_stocks = @stock_purchase.stocks.type_debit
    _cancelled_stocks_product_ids = _cancelled_stocks.uniq.pluck(:product_id)
    _remaining_product_stocks_price = 0
    _cancelled_stocks_product_ids.each do |cancelled_product_id|
      _cancelled_product_stocks_qty = _cancelled_stocks.get_product(cancelled_product_id).sum(:stock_debit)
      _credited_product_stocks = @stock_purchase.stocks.type_credit.get_product(cancelled_product_id)
      _credited_product_stocks_qty = _credited_product_stocks.sum(:stock_credit)
      _credited_product_stocks_price = _credited_product_stocks.sum(:price)
      _remaining_product_stocks_price += ( _credited_product_stocks_price / _credited_product_stocks_qty ) * ( _credited_product_stocks_qty - _cancelled_product_stocks_qty)
    end
    if _cancelled_stocks_product_ids.length > 0
      _remaining_total_product_price = @stock_purchase.stocks.type_credit.get_product_not_in(_cancelled_stocks_product_ids).sum(:price)
    else
      _remaining_total_product_price = @stock_purchase.stocks.type_credit.sum(:price)
    end
    _total_sp_price = _remaining_total_product_price + _remaining_product_stocks_price

    return _total_sp_price
  end
end
