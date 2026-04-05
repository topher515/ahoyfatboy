# ahoyfatboy

Home server running on a Mac Mini.

## Scripts

### `scripts/pmset-always-on.sh`

Configures the Mac to stay always-on by disabling sleep, auto-restarting after power loss, and scheduling a daily power-on as a safety net.

```bash
sudo ./scripts/pmset-always-on.sh apply    # Apply always-on settings
./scripts/pmset-always-on.sh status         # Show current settings
sudo ./scripts/pmset-always-on.sh undo      # Restore macOS defaults
```

### `scripts/docker-autostart.sh`

Sets up Docker Desktop to launch at login and installs a LaunchAgent that runs `docker compose up -d` from the project directory once Docker is ready.

```bash
./scripts/docker-autostart.sh apply    # Enable auto-start
./scripts/docker-autostart.sh status   # Check current state
./scripts/docker-autostart.sh undo     # Disable auto-start
```

Logs go to `/tmp/com.ahoyfatboy.docker-compose.log`.
