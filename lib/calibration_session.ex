defmodule ElixirInterviewStarter.CalibrationSession do
  @moduledoc """
  A struct representing an ongoing calibration session, used to identify who the session
  belongs to, what step the session is on, and any other information relevant to working
  with the session.
  """

  @type t() :: %__MODULE__{}

  defstruct email: "",
            precheck1: nil,
            precheck2: nil,
            cartridge_status: nil,
            submerged_in_water: nil,
            calibrated: nil
end
