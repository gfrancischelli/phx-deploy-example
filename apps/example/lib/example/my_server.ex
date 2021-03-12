defmodule Example.MyServer do
  @moduledoc """
  An example GenServer that runs arbitrary functions and emits telemetry events when called.
  """
  use GenServer

  # A common prefix for :telemetry events
  @prefix [:example, :my_server, :call]

  def start_link(fun) do
    GenServer.start_link(__MODULE__, fun, name: __MODULE__)
  end

  @doc """
  Runs the function contained within this server.

  ## Events

  The following events may be emitted:

    * `[:example, :my_server, :call, :start]` - Dispatched
      immediately before invoking the function. This event
      is always emitted.

      * Measurement: `%{system_time: system_time}`

      * Metadata: `%{}`

    * `[:example, :my_server, :call, :stop]` - Dispatched
      immediately after successfully invoking the function.

      * Measurement: `%{duration: native_time}`

      * Metadata: `%{}`

    * `[:example, :my_server, :call, :exception]` - Dispatched
      immediately after invoking the function, in the event
      the function throws or raises.

      * Measurement: `%{duration: native_time}`

      * Metadata: `%{kind: kind, reason: reason, stacktrace: stacktrace}`
  """
  def call!, do: GenServer.call(__MODULE__, :called)

  @impl true
  def init(fun) when is_function(fun, 0), do: {:ok, fun}

  @impl true
  def handle_call(:called, _from, fun) do
    # Wrap the function invocation in a "span"
    result = telemetry_span(fun)

    {:reply, result, fun}
  end

  # Emits telemetry events related to invoking the function
  defp telemetry_span(fun) do
    start_time = emit_start()

    try do
      fun.()
    catch
      kind, reason ->
        stacktrace = System.stacktrace()
        duration = System.monotonic_time() - start_time
        emit_exception(duration, kind, reason, stacktrace)
        :erlang.raise(kind, reason, stacktrace)
    else
      result ->
        duration = System.monotonic_time() - start_time
        emit_stop(duration)
        result
    end
  end

  defp emit_start do
    start_time_mono = System.monotonic_time()

    :telemetry.execute(
      @prefix ++ [:start],
      %{system_time: System.system_time()},
      %{}
    )

    start_time_mono
  end

  defp emit_stop(duration) do
    :telemetry.execute(
      @prefix ++ [:stop],
      %{duration: duration},
      %{}
    )
  end

  defp emit_exception(duration, kind, reason, stacktrace) do
    :telemetry.execute(
      @prefix ++ [:exception],
      %{duration: duration},
      %{
        kind: kind,
        reason: reason,
        stacktrace: stacktrace
      }
    )
  end
end
