defmodule ElixirInterviewStater.ManageSessionsTest do
  use ExUnit.Case, async: true

  alias ElixirInterviewStarter.CalibrationSessionServer
  alias ElixirInterviewStater.ManageSessions

  setup do
    {:ok, _} = Application.ensure_all_started(:elixir_interview_starter)
    :ok

    {:ok, pid} = ManageSessions.start_link()
    {:ok, pid: pid}
  end

  describe "create_session_server" do
    test "creates a new calibration session server" do
      email = "new_email@example.com"

      {:ok, _pid} = CalibrationSessionServer.start_link(email)
      assert {:ok, session} = ManageSessions.create_session_server(email)
      assert session.email == "new_email@example.com"
    end

    test "create_session_server/1 returns error if session already exists" do
      email = "email@example.com"
      ManageSessions.create_session_server(email)

      assert {:error, "Session already exists"} = ManageSessions.create_session_server(email)
    end
  end

  # describe "execute_precheck2/1" do
  #   test "execute_precheck1/1 executes precheck1 for a valid session", %{pid: pid} do
  #     email= "email@example.com"

  #     send_precheck1(pid, email)

  #     assert {:ok, session} = ManageSessions.create_session_server(email)
  #     assert session.precheck1
  #     assert {:ok, session} = ManageSessions.execute_precheck2(email)
  #     assert session.precheck1
  #   end

  #   test "execute_precheck2/1 executes precheck2 for a valid session" do
  #     session = start_and_fetch_session()
  #     assert {:ok, session} = CalibrationSessionServer.precheck1(session)
  #     assert {:ok, session} = CalibrationSessionServer.precheck2(session)
  #     assert session.status == :precheck2_completed
  #   end
  # end

  describe "fetch_session/1" do
    test "fetches a calibration session" do
      email = "email@example.com"

      assert {:ok, created_session} = ManageSessions.create_session_server(email)
      assert session = ManageSessions.fetch_session(email)
      assert session == created_session
    end
  end

  def start_and_fetch_session do
    {:ok, pid} = CalibrationSessionServer.start_link("email@example.com")
    session = CalibrationSessionServer.fetch_session(pid)
    session
  end

  def send_precheck1(pid, email, result \\ true) do
    pid
    |> :sys.get_state()
    |> Map.get(email)
    |> Process.send(%{"precheck1" => result}, [:ok])
  end
end
