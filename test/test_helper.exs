Enum.map([:jiffy, :ranch, :shackle, :hackney], &Application.ensure_all_started/1)
ExUnit.start()
