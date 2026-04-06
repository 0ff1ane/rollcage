# ============ START CLICKHOUSE SETUP ============

Logger.configure(level: :info)
Calendar.put_time_zone_database(Tz.TimeZoneDatabase)

alias ApiServer.ChRepo

{:ok, _} = Ecto.Adapters.ClickHouse.ensure_all_started(ChRepo.config(), :temporary)

_ = Ecto.Adapters.ClickHouse.storage_down(ChRepo.config())
:ok = Ecto.Adapters.ClickHouse.storage_up(ChRepo.config())

{:ok, _} = ChRepo.start_link()
{:ok, _, _} = Ecto.Migrator.with_repo(ChRepo, &Ecto.Migrator.run(&1, :up, all: true))

# ============ END CLICKHOUSE SETUP ============

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ApiServer.Repo, :manual)
