# frozen_string_literal: true

class BudgetsController < ApplicationController
  skip_load_resource only: %i[index new]
  before_action :set_budget, only: %i[show edit update destroy]

  def index
    @q ||= Budget.accessible_by(current_ability).ransack(params[:q])
    @q.sorts = 'name asc' if @q.sorts.empty?
    @index ||= @q.result(distinct: true).page(params[:page]).per(20)
  end

  def show; end

  def new
    @budget = Budget.new
  end

  def create
    @budget = Budget.new(budget_params)

    respond_to do |format|
      if @budget.save
        format.html { redirect_to budget_url(@budget), notice: t(:budget_create) }
        format.json { render :show, status: :created, location: @budget }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @budget.update(budget_params)
        format.html { redirect_to budget_url(@budget), notice: t(:budget_update) }
        format.json { render :show, status: :updated, location: @budget }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @budget.destroy

    respond_to do |format|
      format.html { redirect_to budgets_url, notice: t(:budget_destroyed) }
      format.json { head :no_content }
    end
  end

  private

  def set_budget
    @budget = Budget.find(params[:id])

    redirect_back(fallback_location: budgets_url) unless @budget
  end

  def budget_params
    params.require(:budget).permit(:name, :description, :amount, :currency, event_ids: [])
  end
end
