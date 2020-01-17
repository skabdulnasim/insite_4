class SetScopeValues < ActiveRecord::Migration
  def up
    AlphaPromotion.update_all(scope: 'global')  	
  end

  def down
  end
end
