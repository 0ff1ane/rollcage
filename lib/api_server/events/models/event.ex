defmodule ApiServer.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "event" do
    field :timestamp, Ch, type: "DateTime64(8)"

    field :event_id, Ch, type: "UUID"
    field :project_id, Ch, type: "UUID"
    field :organization_id, Ch, type: "UUID"

    field :release, Ch, type: "String"

    field :event_type, Ch, type: "LowCardinality(String)"
    field :level, Ch, type: "LowCardinality(String)"

    field :title, Ch, type: "String"
    field :transaction, Ch, type: "String"
    field :search_vector, Ch, type: "String"
    field :metadata, Ch, type: "JSON"
    field :contexts, Ch, type: "JSON"
    field :tags, Ch, type: "JSON"
    field :payload, Ch, type: "JSON"
    field :stackframes, Ch, type: "Array(JSON)"
  end

  @doc false
  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [
      :timestamp,
      :event_id,
      :project_id,
      :organization_id,
      :release,
      :event_type,
      :level,
      :title,
      :transaction,
      :search_vector,
      :metadata,
      :contexts,
      :tags,
      :payload,
      :stackframes
    ])
    |> validate_required([
      :timestamp,
      :event_id,
      :project_id,
      :organization_id,
      :release,
      :event_type,
      :level,
      :title,
      :transaction,
      :search_vector,
      :metadata,
      :contexts,
      :tags,
      :payload,
      :stackframes
    ])
  end
end
