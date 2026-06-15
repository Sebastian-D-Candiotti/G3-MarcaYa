# frozen_string_literal: true

module Infrastructure
  module Orm
    class DeviceRecord < ActiveRecord::Base
      self.table_name = "devices"

      belongs_to :user, class_name: "Infrastructure::Orm::UsuarioRecord",
                         foreign_key: :user_id
    end
  end
end
