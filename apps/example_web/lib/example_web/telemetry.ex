defmodule ExampleWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
      {TelemetryMetricsPrometheus, [metrics: prom_metrics()]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:method, :route],
        tag_values: &get_and_put_http_method/1,
        unit: {:native, :millisecond}
      ),
      summary("phoenix.live_view.mount.stop.duration",
        unit: {:native, :millisecond},
        tags: [:view, :connected?],
        tag_values: &live_view_metric_tag_values/1
      ),

      # Database Metrics
      summary("example.repo.query.total_time", unit: {:native, :millisecond}),
      summary("example.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("example.repo.query.query_time", unit: {:native, :millisecond}),
      summary("example.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("example.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Example Metrics
      last_value("example.users.total"),
      last_value("example.my_server.memory", unit: :byte),
      last_value("example.my_server.message_queue_len"),
      summary("example.my_server.call.stop.duration"),
      counter("example.my_server.call.exception")
    ]
  end

  @doc """
  Prometheus basic metrics that "every" project should probably have.
  See [Prometheus Naming Best Practices](https://github.com/prometheus/docs/blob/master/content/docs/practices/naming.md)
  """
  def prom_metrics do
    [
      # Request rate
      # You will usually want to track the rate of
      # of changes rate(phoenix_endpoint_start[10m])
      counter("phx_router_requests_total",
        tags: [:route],
        event_name: "phoenix.router_dispatch.stop",
        measurement: :duration
      ),
      # Latency
      # Quantiles will indicate how the experience is like for our users
      # histogram_quantile(0.99, rate(phoenix_router_dispatch.stop[10m])
      distribution("phx_router_duration",
        unit: {:native, :millisecond},
        reporter_options: [buckets: http_buckets()],
        tags: [:method, :route],
        tag_values: &get_and_put_http_method/1,
        measurement: :duration,
        event_name: "phoenix.router_dispatch.stop",
        description: "A histogram of the request duration for phoenix http responses"
      ),
      # Error rate
      counter("phx_router_errors_total",
        tags: [:route],
        event_name: "phoenix.router_dispatch.exception",
        measurement: :duration
      )
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      {Example, :measure_users, []},
      {:process_info,
       event: [:example, :my_server], name: Example.MyServer, keys: [:message_queue_len, :memory]}
    ]
  end

  defp get_and_put_http_method(%{conn: %{method: method}} = metadata) do
    Map.put(metadata, :method, method)
  end

  defp live_view_metric_tag_values(metadata) do
    metadata
    |> Map.put(:view, inspect(metadata.socket.view))
    |> Map.put(:connected?, get_connection_status(metadata.socket))
  end

  # Renders the label ExampleWeb.PageLive (Connected|Disconnected)
  # instead of:       ExampleWeb.PageLive (true|false)
  defp get_connection_status(%{connected?: true}), do: "Connected"
  defp get_connection_status(%{connected?: false}), do: "Disconnected"

  defp http_buckets() do
    [
      10,
      25,
      50,
      100,
      250,
      500,
      1000,
      2500,
      5000,
      10000,
      25000,
      50000,
      100_000,
      250_000,
      500_000,
      1_000_000,
      2_500_000,
      5_000_000,
      10_000_000
    ]
  end
end
