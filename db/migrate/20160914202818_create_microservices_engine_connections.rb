# frozen_string_literal: true
class CreateMicroservicesEngineConnections < ActiveRecord::Migration[5.0]
  def change
    create_table :microservices_engine_connections do |t|
      t.string :name
      t.string :object
      t.string :url

      t.timestamps null: false
    end
  end
end