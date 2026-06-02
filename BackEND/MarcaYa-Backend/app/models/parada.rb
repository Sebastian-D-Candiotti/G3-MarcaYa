# frozen_string_literal: true

class Parada < ApplicationRecord
  self.table_name = "paradas"

  # ── Asociaciones ──────────────────────────────────────────────
  belongs_to :obra
  has_many :empleado_paradas, dependent: :destroy
  has_many :empleados, through: :empleado_paradas

  # ── Validaciones ──────────────────────────────────────────────
  validates :nombre, presence: true, length: { maximum: 150 }
  validates :latitud, presence: true
  validates :longitud, presence: true
  validates :radio_metros, presence: true, numericality: { greater_than: 0 }
  validates :estado, presence: true, length: { maximum: 20 }
  validates :nombre, uniqueness: { scope: :obra_id, message: "ya existe una parada con ese nombre en esta obra" }
end
