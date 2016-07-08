Enum.map([:jiffy, :ranch, :shackle], &Application.ensure_all_started/1)
ExUnit.start()
