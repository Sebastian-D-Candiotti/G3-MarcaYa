# frozen_string_literal: true

class EmpleadoParada < ApplicationRecord
  self.table_name = "empleado_paradas"

  # ── Asociaciones ──────────────────────────────────────────────
  belongs_to :empleado
  belongs_to :parada

  # ── Validaciones ──────────────────────────────────────────────
  validates :empleado_id, uniqueness: { scope: :parada_id, message: "ya está asignado a esta parada" }
  validates :estado, presence: true, length: { maximum: 20 }
end
