# frozen_string_literal: true
module MicroservicesEngine
  class Connection < ActiveRecord::Base
    validates :name, :url, :object, presence: true

    def data(*attributes)
      # TO-DO
      # Send a request to the endpoint in the Connection object
    end

    def self.data(objectName, *attributes)
      conn = Connection.where(object: objectName)
      conn ? conn.data(attributes) : {}
    end
  end
end
