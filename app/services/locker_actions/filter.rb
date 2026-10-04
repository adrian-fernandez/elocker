module LockerActions
  class Filter < ApplicationService
    ACTIONS = LockerAction.actions.keys.freeze
    ACTOR_TYPES = %w[platform tenant device].freeze

    def initialize(scope:, params:, model: LockerAction)
      @scope = scope
      @params = params
      @model = model
    end

    def call
      scope = @scope
      scope = by_company(scope)
      scope = by_locker(scope)
      scope = by_user(scope)
      scope = by_team(scope)
      scope = by_action(scope)
      scope = by_actor_type(scope)
      scope = by_date_from(scope)
      scope = by_date_to(scope)
      scope.distinct
    end

    def by_company(scope)
      return scope if @params[:company_id].blank?

      scope.where(company_id: @params[:company_id])
    end

    def by_locker(scope)
      return scope if @params[:locker_id].blank?

      scope.where(locker_id: @params[:locker_id])
    end

    def by_user(scope)
      return scope if @params[:user_id].blank?

      scope.where(user_id: @params[:user_id])
    end

    def by_team(scope)
      return scope if @params[:team_id].blank?

      scope
        .joins("INNER JOIN teams_users ON teams_users.user_id = locker_actions.user_id")
        .where(teams_users: {team_id: @params[:team_id]})
    end

    def by_action(scope)
      value = @params[:action_type].to_s
      return scope unless ACTIONS.include?(value)

      scope.where(action: @model.actions.fetch(value))
    end

    def by_actor_type(scope)
      case @params[:actor_type]
      when "platform"
        scope.joins(user: :company).where(companies: {platform_owner: true})
      when "tenant"
        scope.joins(user: :company).where(companies: {platform_owner: false})
      when "device"
        scope.where(user_id: nil)
      else
        scope
      end
    end

    def by_date_from(scope)
      date = parse_date(@params[:from])
      return scope if date.nil?

      scope.where("locker_actions.created_at >= ?", date.beginning_of_day)
    end

    def by_date_to(scope)
      date = parse_date(@params[:to])
      return scope if date.nil?

      scope.where("locker_actions.created_at <= ?", date.end_of_day)
    end

    private

    def parse_date(value)
      return nil if value.blank?

      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
