module UsersHelper
  def setup_user(user)
    user.profile ||= Profile.new
    user.users_role ||= UsersRole.new
    user
  end
  def load_users_tree(unit)
    @users = User.by_unit(unit.id).order("parent_user_id asc")
    # puts @users.count
    # puts Date.new
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      # Showing user role
      concat(content_tag(:div, :class => "col-lg-12"){
        concat(content_tag(:div, :class => "col-lg-12"){
          concat(content_tag(:span, unit.unittype.unit_type_name.humanize, :class => "m-label teal margin-l-none margin-r-5"))
        })
        # #show User Action
        # concat(content_tag(:div, class: ["col-lg-10 padding-l-r-none"]){
        #   concat(content_tag(:div, '', :class => "float-r"){         
        #     concat(content_tag(:a, '', :href =>edit_unit_path(unit), :class => "m-btn orange waves-effect waves-light m-btn-small margin-r-5"){
        #       concat(content_tag(:i, '', :class => "mdi-editor-border-color"))
        #     })
        #     concat(content_tag(:a, '', :href =>unit_path(unit), data: { confirm: 'Are you sure?' }, :class => "m-btn red waves-effect waves-light m-btn-small margin-r-5"){
        #       concat(content_tag(:i, '', :class => "mdi-action-delete"))
        #     })        
        #   })   
        # })
        concat(content_tag(:div, class: ["col-lg-2 padding-l-r-none"]){
        })
        #Show User name email and branch
        concat(content_tag(:div, class: ["col-lg-10 padding-l-r-none"], :style => "margin-top: -24px;"){
          concat (label_tag( unit.unit_name))
          concat(content_tag(:div, class: ["clearfix"]){})
          concat (content_tag(:p, class: ["margin-t-b-0"]){
          concat (content_tag(:ul, class: ["collection-child"]){
            concat(content_tag(:br))
            if @users.present?
              concat(content_tag(:table, :class => "data-table"){
                concat(content_tag(:tr){
                  concat(content_tag(:th, "ID", :class => "col-lg-1"))
                  concat(content_tag(:th, "Parent User", :class => "col-lg-2"))
                  concat(content_tag(:th, "Email", :class => "col-lg-2"))
                  concat(content_tag(:th, "UserName",:class => "col-lg-1"))
                  concat(content_tag(:th, "Role",:class => "col-lg-1"))
                  concat(content_tag(:th, "PIN",:class => "col-lg-1"))
                  concat(content_tag(:th, "Created",:class => "col-lg-1"))
                  concat(content_tag(:th, "LastSignIn",:class => "col-lg-1"))
                  concat(content_tag(:th, "Custom sync",:class => "col-lg-1"))
                  concat(content_tag(:th, "Actions",:class => "col-lg-1"))
                })
                @users.each do |object|
                  @calculate_days = (Date.today - object.created_at.to_date).to_i
                  year = @calculate_days / 365
                  day1 = @calculate_days % 365
                  month = day1 / 30 
                  day = day1 % 30 
                  y = (year > 1) ? "Years" : "Year"
                  m = (month >1) ? "Months" : "Month"
                  d = (day> 1) ? "Days" : "Day"
                  concat(content_tag(:tr){
                    concat(content_tag(:td,object.id, :class => "col-lg-1"))
                    if User.find_by_id(object.parent_user_id).present?
                      concat(content_tag(:td,User.find_by_id(object.parent_user_id).profile.firstname+" "+User.find_by_id(object.parent_user_id).profile.lastname,:class => "col-lg-2"))
                    else
                      concat(content_tag(:td, "-",:class => "col-lg-2"))
                    end
                    concat(content_tag(:td, object.email.present? ? object.email : "-",:class => "col-lg-2"))
                    concat(content_tag(:td, object.profile.firstname+" "+object.profile.lastname,:class => "col-lg-2"))
                    concat(content_tag(:td, object.role.present? ? object.role.name.humanize : "-",:class => "col-lg-2"))
                    concat(content_tag(:td, object.key_phrase.present? ? object.key_phrase.to_s : "-",:class => "col-lg-1"))
                    concat(content_tag(:td, year.to_s+" "+y+" "+month.to_s+" "+m+" "+day.to_s+" "+d +" "+"ago",:class => "col-lg-1"))
                    if object.sign_in_count > 0
                      concat(content_tag(:td, object.current_sign_in_at.strftime("%Y-%b-%d %I:%M%p"), :class => "col-lg-1"))
                    else
                      concat(content_tag(:td, "-", :class => "col-lg-1"))
                    end
                    # concat(content_tag(:td, object.current_sign_in_at.strftime("%Y-%b-%d %I:%M%p").present? ? object.current_sign_in_at.strftime("%Y-%b-%d %I:%M%p") : "-", :class => "col-lg-1"))
                    custom_sync_value = object.custom_sync == 'enable' ? true : false
                    concat(content_tag(:td, '', :class => "col-lg-1"){
                      concat(content_tag(:div, :class => "switch padding-5"){
                        concat(content_tag(:label){
                          concat(content_tag(:input, '', :checked => custom_sync_value, :class => 'update_custom_sync', 'data-user-id' => object.id, 'data-value-active' => 'enable', 'data-value-inactive' => 'disable', :id => "custom_sync_#{object.id}", :name => 'custom_sync', :type => 'checkbox', :value => 'enable'))
                          concat(content_tag(:span, '',   :class => 'lever'))
                        })
                      })
                    })
                    if current_user.role.name == 'owner' || current_user.role.name =='dc_manager' || current_user.role.name =='outlet_manager' || current_user.role.name =="bill_manager"
                      concat(content_tag(:td, '', :class => "col-lg-2"){
                        if can? :profile, User
                          concat(content_tag(:a, '', :href =>new_user_path(), :class => "m-btn green waves-effect waves-light m-btn-small margin-r-5 "){
                          concat(content_tag(:i, '', :class => "mdi-content-add"))
                          })
                        end
                        if can? :edit, User          
                          concat(content_tag(:a, '', :href =>edit_user_path(object), :class => "m-btn orange waves-effect waves-light m-btn-small margin-r-5"){
                            concat(content_tag(:i, '', :class => "mdi-editor-border-color"))
                          })
                        end
                        if can? :delete_user, User
                          concat(content_tag(:a, '', :href =>delete_user_path(object), :class => "m-btn red waves-effect waves-light m-btn-small margin-r-5", :method => :delete, :data => { :confirm => t('.confirm', :default => t("helpers.links.confirm", :default => 'Are you sure?'))} ){
                            concat(content_tag(:i, '', :class => "mdi-action-delete"))
                          })
                        end
                        if can? :toggle_status, User
                          if object.status == 1 
                            concat(content_tag(:a, '', :href =>toggle_status_user_path(object), :class => "m-btn indigo m-btn-small waves-effect waves-light"){
                              concat(content_tag(:i, '', :class => "mdi-action-settings-power"))
                            })
                          else
                            concat(content_tag(:a, '', :href =>toggle_status_user_path(object), :class => "m-btn amber m-btn-small waves-effect waves-light"){
                              concat(content_tag(:i, '', :class => "mdi-action-settings-power"))
                            })
                          end
                        end
                      })
                    else
                      concat(content_tag(:td,"-", :class => "col-lg-1"))
                    end
                  })
              end
            })
          end
          }) 
          })       
        })
      })
      
      concat(content_tag(:div, class: ["clearfix"]){})
      #Recursive call to get the child units
      _child_units = Unit.set_parent_unit(unit.id)
      if _child_units.present?
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |cu|
            load_users_tree(cu)    
          end
        })     
      end    
    })
  end
end