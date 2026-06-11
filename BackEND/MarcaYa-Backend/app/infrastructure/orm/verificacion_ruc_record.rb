# frozen_string_literal: true

module Infrastructure
  module Orm
    class VerificacionRucRecord < ActiveRecord::Base
      self.table_name = "verificaciones_ruc"

      validates :ruc, presence: true, uniqueness: true
      validates :codigo, presence: true
      validates :expira_at, presence: true

      def activo?
        expira_at > Time.current
      end
    end
  end
end
