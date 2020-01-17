module MenuManagement
  def self.get_menu_product_details_by_id(id)
    _menu_product_details=MenuProduct.find(id)
    return _menu_product_details
  end
  
  def self.get_menu_card_details_by_id(id)
    _menu_card_details=MenuCard.find(id)
    return _menu_card_details
  end
  
  
  def self.create_menu_product(product_id, price,ammount,product_unit_id, menu_product_id, combination_type_id, combinations_rule_id, addons_group_id, addons_group_product_id)
    #puts product_id
    menu_product_combination = MenuProductCombination.new
    menu_product_combination[:product_id] = product_id
    menu_product_combination[:combination_type_id] = combination_type_id
    menu_product_combination[:combinations_rule_id] = combinations_rule_id
    menu_product_combination[:price] = price.to_f
    menu_product_combination[:menu_product_id] = menu_product_id
    menu_product_combination[:ammount] = ammount.to_f
    menu_product_combination[:product_unit_id] = product_unit_id
    menu_product_combination[:addons_group_id] = addons_group_id
    menu_product_combination[:addons_group_product_id] = addons_group_product_id
    menu_product_combination.save
  end
  
  def self.get_menu_products()
    return Product.get_all
  end
  
  def self.get_activated_menu_products(unit_id)
   _all_menu_products = Array.new
   _menu_cards = MenuCard.where('unit_id =? AND mode =?', unit_id, 1)
    _menu_cards.each do |_menu_card|
      _menu_products = MenuProduct.where('menu_card_id =?', _menu_card.id)
      _menu_products.each do |_menu_product|
        _all_menu_products.push _menu_product
      end
    end
    _all_menu_products = _all_menu_products.uniq{|x| x.product_id}
    return _all_menu_products
  end

  def self.get_production_section_activated_menu_products(unit_id)
   _all_menu_products = Array.new
   _menu_cards = MenuCard.set_unit(unit_id).set_mode(1).joins(:section).merge(Section.by_section_type('production'))
    _menu_cards.each do |_menu_card|
      _menu_products = MenuProduct.where(:menu_card_id => _menu_card.id)
      _menu_products.each do |_menu_product|
        _all_menu_products.push _menu_product
      end
    end
    _all_menu_products = _all_menu_products.uniq{|x| x.product_id}
    return _all_menu_products
  end
  
  def self.get_all_menu_card_id_by_unit_id(unit_id)
    _menu_card_ids = MenuCard.where(:unit_id => unit_id).select('id')
  end
  
  def self.get_product_array_by_combination_type(menu_product_id, combination_type_id)
    menu_product_combinations_products_arr = Array.new
    menu_product_combinations_products = MenuProductCombination.where("menu_product_id =? AND combination_type_id =?", menu_product_id, combination_type_id).select('product_id')
    menu_product_combinations_products.each do |menu_product_combinations_product|
      menu_product_combinations_products_arr.push menu_product_combinations_product[:product_id]
    end
    return menu_product_combinations_products_arr
  end
  
  def self.get_product_details_by_combination_type(menu_product_id, combination_type_id, product_id)
    menu_product_combinations_products = MenuProductCombination.where("menu_product_id =? AND combination_type_id =? AND product_id =?", menu_product_id, combination_type_id, product_id).last
  end
  
  def self.get_combination_rule_by_combination_type(menu_product_id, combination_type_id)
    menu_product_combinations_rule = MenuProductCombination.where("menu_product_id =? AND combination_type_id =?", menu_product_id, combination_type_id).select('combinations_rule_id').last
  end
  
  def self.get_total_simple_tax(menu_product_id)
    _total_simple_tax = 0
    _product_id = MenuProduct.find(menu_product_id)[:product_id]
    _product_meta_tax = ProductManagement::get_product_meta(_product_id, "tax")
    _product_simple_tax_arr = _product_meta_tax['simple_tax']
    if !_product_simple_tax_arr.empty?
      _total_simple_tax = 0
      _product_simple_tax_arr.each do|p_s_t|
        _total_simple_tax = _total_simple_tax + (TaxClass.get_tax_ammount(p_s_t)[0]['ammount']).to_f
      end
    end
    return _total_simple_tax
  end
  
  def self.get_total_cess_tax(menu_product_id)
    _total_cess_tax = {}
    _product_id = MenuProduct.find(menu_product_id)[:product_id]
    _product_meta_tax = ProductManagement::get_product_meta(_product_id, "tax")
    _product_cess_tax_arr = _product_meta_tax['cess_tax']
    _product_cess_tax_id = _product_cess_tax_arr['cess_tax_class_id']
    _product_cess_tax = TaxClass.get_tax_ammount(_product_cess_tax_id)[0]['ammount']
    _product_cess_tax_on_id = _product_cess_tax_arr['cess_tax_on_id']
    _product_cess_tax_on = TaxClass.get_tax_ammount(_product_cess_tax_on_id)[0]['ammount']
    _total_cess_tax[:product_cess_tax] = _product_cess_tax
    _total_cess_tax[:product_cess_tax_on] = _product_cess_tax_on
    return _total_cess_tax
  end
  
  def self.copy_menu(menucard_from_id, menucard_to_id)
    
    
    owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
    _from_menu_card = MenuCard.find(menucard_from_id)
    _menu_card = MenuCard.find(menucard_to_id)
    _menu_card[:master_menu_id] = menucard_from_id
    _menu_card.save

    _variable_products = Array.new
    _variance_products = Array.new
    _other_products = Array.new
    _menu_product_details = MenuProduct.where("menu_card_id = ?", menucard_from_id)
    _menu_product_details.each do |m_p_d|
      if m_p_d[:variable_id].nil?
        _other_products.push m_p_d[:id]
      else
        _variable_products.push m_p_d[:variable_id]
        _variance_products.push m_p_d[:id]
      end
    end
    _simple_products = _other_products.reject{|x| _variable_products.include? x}
    _variable_products = _variable_products.uniq
    # puts _variable_product
    # puts _variance_product
    # puts _other_product
    # puts _simple_products
    
    ################################# Create Simple Products ##########################
    _simple_products.each do |_simple_product|
      simple_product_instance = MenuProduct.find(_simple_product)
      new_simple_menu_product = MenuProduct.find(_simple_product).dup
      new_simple_menu_product[:menu_card_id] = menucard_to_id


      if owner_will_crud_menu == '1'
        MenuManagement::check_tg_section_sort(simple_product_instance, _menu_card, new_simple_menu_product)
      end
      new_simple_menu_product.save

      ################################# Create Simple Product combination ##########################
      _simple_product_combinations = MenuProductCombination.where(:menu_product_id => _simple_product)
      if _simple_product_combinations.present?
        _simple_product_combinations.each do |_simple_product_combination|
          _new_simple_product_combination = MenuProductCombination.find(_simple_product_combination[:id]).dup
          _new_simple_product_combination[:menu_product_id] = new_simple_menu_product[:id]
          _new_simple_product_combination.save
        end
      end
    end
    
    ################################# Create variable Products ##########################
    _variable_products.each do |_variable_product|
      # puts _variable_product
      prev_variable_menu_product = MenuProduct.find(_variable_product)
      new_variable_menu_product = prev_variable_menu_product.dup
      new_variable_menu_product[:menu_card_id] = menucard_to_id

      if owner_will_crud_menu == '1'
        MenuManagement::check_tg_section_sort(prev_variable_menu_product, _menu_card, new_variable_menu_product)
      end
      new_variable_menu_product.save
      ################################# Create variable Product combination ##########################
      _variable_product_combinations = MenuProductCombination.where(:menu_product_id => _variable_product)
        if _variable_product_combinations.present?
          _variable_product_combinations.each do |_variable_product_combination|
            _new_variable_product_combinations = MenuProductCombination.find(_variable_product_combination[:id]).dup
            _new_variable_product_combinations[:menu_product_id] = new_variable_menu_product[:id]
            _new_variable_product_combinations.save
          end
        end
        
      
      ################################# Create variance of this variable Product ##########################
      _variance_of_this_variable = MenuProduct.where(:variable_id => prev_variable_menu_product[:id])
      _variance_of_this_variable.each do |_variance|
        prev_variance_menu_product = MenuProduct.find(_variance)
        new_variance_menu_product = prev_variance_menu_product.dup
        new_variance_menu_product[:menu_card_id] = menucard_to_id
        new_variance_menu_product[:variable_id] = new_variable_menu_product[:id]
        if owner_will_crud_menu == '1'
          MenuManagement::check_tg_section_sort(prev_variance_menu_product, _menu_card, new_variance_menu_product)
        end
        new_variance_menu_product.save
        
        ################################# Create variance Product combination ##########################
        _variance_product_combinations = MenuProductCombination.where(:menu_product_id => _variance)
        if _variance_product_combinations.present?
          _variance_product_combinations.each do |_variance_product_combination|
            _new_variance_product_combinations = MenuProductCombination.find(_variance_product_combination[:id]).dup
            _new_variance_product_combinations[:menu_product_id] = new_variance_menu_product[:id]
            _new_variance_product_combinations.save
          end
        end
      end
    end
    MenuManagement::copy_menu_categories(menucard_from_id, menucard_to_id)
  end
  
  def self.copy_menu_categories(menucard_from_id, menucard_to_id)
    logs = Hash.new
    _menu_categories = MenuCategory.where(:menu_card_id => menucard_from_id)
    if _menu_categories.present?                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
      _menu_categories.each do |menu_category|
        _new_menu_category = MenuCategory.find(menu_category[:id]).dup
        _new_menu_category[:menu_card_id] = menucard_to_id
        _new_menu_category.save
        logs[menu_category[:id]] = _new_menu_category[:id]
        if menu_category[:parent].present?
          _category = MenuCategory.find(_new_menu_category[:id])
          #logs.has_key?(_new_menu_category[:id])
          _category[:parent] = logs[menu_category[:parent]]
          _category.save
        end
        MenuManagement::update_new_menu_card_categories(menu_category[:id], menucard_to_id, _new_menu_category[:id])
      end
    end
    puts logs
  end
  
  def self.update_new_menu_card_categories(from_menu_category_id, menucard_to_id, to_menu_category_id)
    _menu_products = MenuProduct.where('menu_card_id =? AND menu_category_id =?', menucard_to_id, from_menu_category_id)
    _menu_products.each do |_menu_product|
      _menu_product[:menu_category_id] = to_menu_category_id
      _menu_product.save
    end
  end

  def self.check_tg_section_sort(simple_product_instance, to_menu_card, new_simple_menu_product)
    # check fot Tax Group ans Section same
    puts "Tax group in"
    if simple_product_instance.tax_group_id.present? 
      tax_group_exist = TaxGroup.joins(:section).where("tax_groups.name =(?) AND sections.name =(?) AND sections.unit_id =(?)", simple_product_instance.tax_group.name, to_menu_card.section.name, to_menu_card.section.unit_id)
      
      if tax_group_exist.present?
        new_simple_menu_product[:tax_group_id] = tax_group_exist[0].id
      else
        exit
      end
    end
    puts "Tax group out"
    #####################################

    # check for Store name
    puts "Store in"
    if simple_product_instance.store_id.present? 
      store_exist = Store.where("name =(?) AND unit_id =(?)", simple_product_instance.store.name, to_menu_card.unit_id)
      if store_exist.present?
        new_simple_menu_product[:store_id] = store_exist[0].id
      else
        exit
      end
    end
    puts "Store out"
    ########################################################

    # check for SORT same
    puts "SORT in"
    if simple_product_instance.sort_id.present? 
      sort_exist = Sort.where("name =(?) AND unit_id =(?)", simple_product_instance.sort.name, to_menu_card.unit_id)
      if sort_exist.present?
        new_simple_menu_product[:sort_id] = sort_exist[0].id
      else
        exit
      end
    end
    puts "SORT out"
    ########################################################
  end
end