# Calibrating a Pool Chemistry Monitoring Device

## Usage

To garantee the use of the correct version of Erlang and Elixir,
you can run the following command

```
$ asdf install
```

To install dependencies and compile the project

```elixir
$ mix deps.get
$ mix compile
$ iex -S mix
```

To run the tests

```elixir
$ mix test
```

### Explanation

Creating of the gen server `manage_sessions.ex` to handle api calls to create and manage different calibrate sessions for each user.

Creating of the gen server `calibration_sessions_server.ex` to handle procedure of each session

Since the implementation of the returning responses of the device was not created the test of the `Manage Sessions Server` and `Elixir Interview Starter` wasn't written. The test continued to TIMEOUT.
# calibration
