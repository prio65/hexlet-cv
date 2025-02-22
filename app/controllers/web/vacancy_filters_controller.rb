# frozen_string_literal: true

class Web::VacancyFiltersController < Web::ApplicationController
  def show
    @options = fetch_options(params[:id])

    scope = Vacancy.web.page(params[:page])

    options_for_header = {
      position_level: '',
      direction: '',
      city_description: ''
    }

    @options.each do |key, value|
      case key
      when 'level'
        scope = scope.where(position_level: value)
        options_for_header[:position_level] = I18n.t(value, scope: 'enumerize.position_level')
      when 'direction'
        scope = scope.tagged_with value
        options_for_header[:direction] = value
      when 'city'
        decoded_city_name = Slug.decode(value).downcase
        scope = scope.where(city_name: decoded_city_name)
        options_for_header[:city_description] = I18n.t('in_the_city', city_name: decoded_city_name.capitalize)
        options_for_header[:city_name] = decoded_city_name.capitalize
      end
    end

    keys = %i[position_level direction city_name]
    main_key = keys.find { |k| options_for_header.key? k }

    @header = t(".options.#{main_key}.header", **options_for_header)
    @title = t(".options.#{main_key}.title", **options_for_header)
    @description = t(".options.#{main_key}.description", **options_for_header)

    @vacancies = scope
  end

  private

  def fetch_options(params)
    options = params.split('_').map { |value| value.split('-', 2) }
    if options.filter { |_k, v| v.blank? }.any?
      raise ActionController::RoutingError, 'Not Found'
    end

    options
  end
end
