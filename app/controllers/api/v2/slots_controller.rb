module Api
  module V2
    class SlotsController < ApplicationController
      #before_filter :authenticate_user_with_token!, only: [:get_available_slot,:get_available_order_slot]

      api :GET, '/api/v2/slots', "List of all slots."
      param :email, String, :required => true, :desc => "email of registered user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Unit id of the current unit"
      param :date, String, :required => false, :desc => "Get only avalible slot of this date"
      def index
        @slots = Slot.enabled
        @slots = @slots.by_unit(params[:unit_id]) if params[:unit_id].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
      end

      api :GET, '/api/v2/get_available_slot', "Show only avaliable slot"
      param :email, String, :required => true, :desc => "email of registered user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :date, String, :required => false, :desc => "date is required for filter"
      param :slot_id, String, :required => true, :desc => "avaliable slot of this slot"
      param :resource, String, :required => true, :desc => "avaliable slot of this resource"
      param :unit_id, String, :required => false, :desc => "avaliable slot of this unit"
      def get_available_slot
        _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
        _date = params[:date].present? ? params[:date] : Date.today
        @slot_id = params[:slot_id]
        @reservations = Reservation.by_resource(params[:resource]).by_date(_date).by_unit(_unit_id).by_slot(params[:slot_id]).order("end_time DESC")
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
      end

      api :GET, '/api/v2/get_resource_slot', "Show only avaliable slot of resource"
      param :email, String, :required => true, :desc => "email of registered user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :date, String, :required => true, :desc => "date is required for filter"
      param :resource_id, String, :required => true, :desc => "Get only slots of this resource's"
      def get_resource_slot
        @availability = Availability.by_date(params[:date]).by_resource(params[:resource_id]) if params[:date].present? && params[:resource_id].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
      end

      api :GET, '/api/v2/slots/get_available_order_slot', "Fetching availability of slots for placing order"
      param :email, String, :required => true, :desc => "email of registered user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Unit id of the current unit"
      param :delivery_mode, String, :required => false, :desc => "Delivery mode for an order"
      def get_available_order_slot
        _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
        unit = Unit.find(_unit_id)
        _delivery_mode = params[:delivery_mode].present? ? params[:delivery_mode].humanize : 'Standard'
        _current_date = Date.today
        # _next_date = _delivery_mode == 'Express' ? _current_date : _current_date + 1
        if unit.unit_detail.options[:slot_applicable_from] == 'Today'
          _next_date = _current_date
        elsif unit.unit_detail.options[:slot_applicable_from] == 'Tomorrow'
          _next_date = _current_date + 1
        elsif unit.unit_detail.options[:slot_applicable_from] == 'Day After Tomorrow'
          _next_date = _current_date + 2
        else
          _next_date = _current_date  
        end
        _slot_allow = unit.unit_detail.present? ? unit.unit_detail.options[:day_allow_for_order_slot].to_i : 7
        _upto_date = _current_date + _slot_allow
        _unit_slots = unit.slots.enabled.order("start_time asc")
        _unit_slots = params[:delivery_mode].humanize == 'Express' ? _unit_slots.by_slot_type('Express') : _unit_slots.by_slot_type('Standard')
        @order_slot_details = Array.new

        (_next_date.._upto_date).each do |slot_date|
          _order_slot_data = {}
          _hash = Array.new
          _unit_slots.each do |slot|
            _arr = {}
            _order_placed = OrderSlot.by_slot(slot.id).by_delivery_date(slot_date).count
            _max_booking = slot.max_booking
            _order_availability = _max_booking - _order_placed
            # if slot_date == _current_date
            #   if (Time.now + 90*60).strftime("%H:%M") < slot.start_time.strftime("%H:%M")
            #     _arr[:slot_id] = slot.id
            #     _arr[:slot_title] = slot.title
            #     _arr[:start_time] = slot.start_time.strftime("%H:%M")
            #     _arr[:end_time] = slot.end_time.strftime("%H:%M")
            #     _arr[:availability] = _order_availability
            #   end
            # else
            #   _arr[:slot_id] = slot.id
            #   _arr[:slot_title] = slot.title
            #   _arr[:start_time] = slot.start_time.strftime("%H:%M")
            #   _arr[:end_time] = slot.end_time.strftime("%H:%M")
            #   _arr[:availability] = _order_availability
            # end
            
            if _delivery_mode == 'Standard'
              if slot_date == _current_date
                if Time.now.utc.in_time_zone("Kolkata").strftime("%H:%M") < slot.start_time.strftime("%H:%M")
                  _arr[:slot_id] = slot.id
                  _arr[:slot_title] = slot.title
                  _arr[:start_time] = slot.start_time.strftime("%H:%M")
                  _arr[:end_time] = slot.end_time.strftime("%H:%M")
                  _arr[:availability] = _order_availability
                end
              else
                _arr[:slot_id] = slot.id
                _arr[:slot_title] = slot.title
                _arr[:start_time] = slot.start_time.strftime("%H:%M")
                _arr[:end_time] = slot.end_time.strftime("%H:%M")
                _arr[:availability] = _order_availability
              end
            elsif _delivery_mode == 'Express'
              if slot_date == _current_date
                if (Time.now.utc + 90*60).in_time_zone("Kolkata").strftime("%H:%M") < slot.end_time.strftime("%H:%M")
                  _arr[:slot_id] = slot.id
                  _arr[:slot_title] = slot.title
                  _arr[:start_time] = slot.start_time.strftime("%H:%M")
                  _arr[:end_time] = slot.end_time.strftime("%H:%M")
                  _arr[:availability] = _order_availability
                end
              else
                _arr[:slot_id] = slot.id
                _arr[:slot_title] = slot.title
                _arr[:start_time] = slot.start_time.strftime("%H:%M")
                _arr[:end_time] = slot.end_time.strftime("%H:%M")
                _arr[:availability] = _order_availability
              end
            end
            _hash.push _arr if !_arr.empty?
          end
          _order_slot_data[slot_date] = _hash
          @order_slot_details.push _order_slot_data
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end