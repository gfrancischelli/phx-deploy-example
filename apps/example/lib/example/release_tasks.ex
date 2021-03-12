defmodule App.ReleaseTasks do
  @apps [:app]
  @start_apps [:postgrex, :ecto, :ecto_sql]

  def eval_migrate do
    {:ok, _} = Application.ensure_all_started(:app)

    # path = Application.app_dir(:app, "priv/repo/migrations")

    # Ecto.Migrator.run(MyApp.Repo, path, :up, all: true)

    for repo <- get_repos(:app) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :init.stop()
  end

  def eval_createdb do
    # Start postgrex and ecto
    IO.puts("Starting dependencies...")

    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    Enum.each(@apps, &create_db_for/1)
    IO.puts("createdb task done!")
  end

  # This is here mostly because docker-compose will need it.
  # Real production databases should not probably not allow app
  # users to create databases.
  defp create_db_for(app) do
    for repo <- get_repos(app) do
      :ok = ensure_repo_created(repo)
    end
  end

  defp get_repos(app) do
    Application.load(app)
    Application.fetch_env!(app, :ecto_repos)
  end

  defp ensure_repo_created(repo) do
    IO.puts("create #{inspect(repo)} database if it doesn't exist")

    case repo.__adapter__.storage_up(repo.config) do
      :ok -> :ok
      {:error, :already_up} -> :ok
      {:error, term} -> {:error, term}
    end
  end
end
