# frozen_string_literal: true

class CronogramaDePago < ApplicationRecord
  self.table_name = "cronograma_de_pagos"

  belongs_to :empleado
  belongs_to :obra

  validates :periodo, presence: true
  validates :estado, inclusion: { in: %w[pendiente aprobado sincronizado pagado] }

  scope :del_empleado, ->(empleado_id) { where(empleado_id: empleado_id) }
  scope :de_obra, ->(obra_id) { where(obra_id: obra_id) }
  scope :pendientes, -> { where(estado: "pendiente") }
  scope :aprobados, -> { where(estado: "aprobado") }
end
