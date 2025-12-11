# frozen_string_literal: true

class TravelSponsorshipsController < ApplicationController
  skip_load_resource only: %i[index new]
  helper_method :request_states_collection
  before_action :load_subjects
  before_action :set_event, only: [:new]
  before_action :set_travel_sponsorship, only: %i[show edit update destroy]

  def index
    @q ||= TravelSponsorship.accessible_by(current_ability).includes(:expenses).ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty?
    @all_requests ||= @q.result(distinct: true)
    @travel_sponsorships ||= @all_requests.page(params[:page]).per(20)
    @requests = @travel_sponsorships
  end

  def show
    @request = @travel_sponsorship
  end

  def new
    @travel_sponsorship = TravelSponsorship.new
    @travel_sponsorship.event = @event
    @travel_sponsorship.user = current_user
    previous = TravelSponsorship.in_conflict_with(@travel_sponsorship).first
    redirect_to previous, alert: I18n.t(:redirect_to_previous_request) if previous

    authorize! :create, @travel_sponsorship
    @travel_sponsorship.expenses.build
  end

  def create
    @travel_sponsorship = TravelSponsorship.new(travel_sponsorship_params)
    @travel_sponsorship.user = current_user

    respond_to do |format|
      if @travel_sponsorship.save
        format.html { redirect_to travel_sponsorship_url(@travel_sponsorship), notice: t(:travel_sponsorship_create) }
        format.json { render :show, status: :created, location: @travel_sponsorship }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @travel_sponsorship.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @travel_sponsorship.update(travel_sponsorship_params)
        format.html { redirect_to travel_sponsorship_url(@travel_sponsorship), notice: t(:travel_sponsorship_update) }
        format.json { render :show, status: :updated, location: @travel_sponsorship }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @travel_sponsorship.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @travel_sponsorship.destroy

    respond_to do |format|
      format.html { redirect_to travel_sponsorships_url, notice: t(:travel_sponsorship_destroyed) }
      format.json { head :no_content }
    end
  end

  private

  def request_states_collection
    TravelSponsorship.state_machines[:state].states.map { |s| [s.human_name, s.value] }
  end

  def set_event
    @event = Event.find(params[:event_id])

    redirect_back(fallback_location: events_url) unless @event
  end

  def set_travel_sponsorship
    @travel_sponsorship = TravelSponsorship.find(params[:id])

    redirect_back(fallback_location: budgets_url) unless @travel_sponsorship
  end

  def load_subjects
    @subjects = Rails.configuration.site['travel_sponsorships']['expenses_subjects']
  end

  def travel_sponsorship_params
    expenses_attributes = %i[id subject description estimated_amount estimated_currency _destroy]
    params.require(:travel_sponsorship).permit(:event_id, :description, :visa_letter, expenses_attributes: expenses_attributes)
  end
end
