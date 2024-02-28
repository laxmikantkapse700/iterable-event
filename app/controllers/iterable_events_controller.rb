class IterableEventsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update]


  def index
    @iterable_events = IterableEvent.all
  end
  
  def new
    @iterable_event = IterableEvent.new
  end

  def create
    @type = params[:iterable_event][:type]
    @title = params[:iterable_event][:title] 
    success, results = IterableEvent.new.create_event(@type, @title, current_user) 
    if success
      if @type == 'A'
        event = results
        flash[:success] = "Event created successfully"
        redirect_to iterable_events_path
      elsif @type == 'B'
        event, notification = results
        if event.present? && notification.present?
          flash[:success] = "Event and Notification created successfully"
          redirect_to iterable_events_path
        elsif event.present?
          flash[:error] = "Failed to create notification"
          redirect_to iterable_events_path
        else
          flash[:error] = "Failed to create event"
          redirect_to iterable_events_path
        end
      end
    else
      flash[:error] = "Failed to create event or notification"
      redirect_to iterable_events_path
    end
  end


  def show
  end

  def edit
  end

  def update
    user_ids = params[:user_ids]
    event = IterableEvent.new.update_event(@iterable_event, user_ids)
    if event
      flash[:notice] = "users added sucessfully"
      redirect_to iterable_event_path(event)
    else
      flash[:alert] = "not able to add users"
      redirect_to iterable_event_path(@iterable_event.id)
    end
  end


  private

  def set_event
    @iterable_event = IterableEvent.find_by(id: params[:id])
  end
end