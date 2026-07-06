# frozen_string_literal: true

class EvaluarAusenciasJob < ApplicationJob
  queue_as :default

  def perform
    alerta_ausencia_facade = Rails.configuration.di.alerta_ausencia_facade
    alerta_ausencia_facade.evaluar_ausencias
  end
end
