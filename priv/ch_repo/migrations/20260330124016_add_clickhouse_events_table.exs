defmodule ApiServer.ChRepo.Migrations.AddClickhouseEventsTable do
  use Ecto.Migration

  def up do
    create table(:event,
             primary_key: false,
             engine: "MergeTree",
             options: [order_by: "(organization_id, project_id, timestamp)"]
           ) do
      add(:timestamp, :"DateTime64(8)", nullable: false)

      add(:event_id, :UUID, nullable: false)
      add(:project_id, :UUID, nullable: false)
      add(:organization_id, :UUID, nullable: false)

      add(:release, :String, nullable: true)

      add(:event_type, :"LowCardinality(String)", nullable: true)
      add(:level, :"LowCardinality(String)", nullable: true)

      add(:title, :String, nullable: false)
      add(:transaction, :String, nullable: true)
      add(:search_vector, :String, nullable: false)
      add(:metadata, :JSON, nullable: false)
      add(:contexts, :JSON, nullable: false)
      add(:tags, :JSON, nullable: false)
      add(:payload, :JSON, nullable: false)
      add(:stackframes, :"Array(JSON)", nullable: true)
    end
  end

  def down do
    drop table(:event)
  end
end
