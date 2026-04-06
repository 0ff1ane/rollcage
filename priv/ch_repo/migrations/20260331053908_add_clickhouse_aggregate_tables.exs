defmodule ApiServer.ChRepo.Migrations.AddClickhouseAggregateTables do
  use Ecto.Migration

  def up do
    [
      """
      CREATE TABLE events_hourly
      (
          hour DateTime,
          organization_id UUID,
          project_id UUID,
          event_count UInt64,
          event_type LowCardinality(String),
          unique_level LowCardinality(String),
          unique_title String
      )
      ENGINE = SummingMergeTree()
      PARTITION BY toYYYYMM(hour)
      ORDER BY (organization_id, project_id, event_type, hour)
      """,
      """
        CREATE MATERIALIZED VIEW events_hourly_mv TO events_hourly AS
        SELECT
            toStartOfHour(timestamp) AS hour,
            organization_id,
            project_id,
            event_type,
            count() AS event_count,
            uniq(level) AS unique_level,
            uniq(title) AS unique_title
        FROM events
        GROUP BY organization_id, project_id, event_type, hour
      """
    ]
  end

  def down do
    [
      "DROP MATERIALIZED VIEW events_hourly_mv",
      "DROP TABLE events_hourly"
    ]
  end
end
