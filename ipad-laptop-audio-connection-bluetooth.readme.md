## What to do when iPad to Laptop to Headphones audio seems buggy

Run:

```bash
bluetoothctl devices Paired
```

Find the iPad’s MAC address, then check it:

```bash
bluetoothctl info XX:XX:XX:XX:XX:XX
```

Look for:

```text
Paired: yes
Trusted: yes
```

If `Trusted` is `no`, run:

```bash
bluetoothctl trust XX:XX:XX:XX:XX:XX
```

Trusted devices are allowed to reconnect and use Bluetooth services without repeatedly requiring authorization. Pairing through `bluetoothctl` normally marks the device as trusted automatically, but it is worth confirming since you originally paired through the graphical interface. ([GitHub][1])

### When it disconnects

First try tapping your Ubuntu computer under **Settings → Bluetooth** on the iPad.

If that does not reconnect it, restart WirePlumber:

```bash
systemctl --user restart wireplumber
```

If it is still stuck:

```bash
sudo systemctl restart bluetooth
```

The second command disconnects your headphones too, so reconnect the headphones and then the iPad.

### Watch for screen locking

Pay attention to whether it disconnects after:

* Ubuntu locks
* Ubuntu suspends
* You switch users
* The monitor has been off for a while

WirePlumber normally makes Bluetooth audio available only to the currently active graphical login session. Session changes can therefore affect long-running Bluetooth audio connections. Ubuntu 26.04 currently ships WirePlumber 0.5.13, which supports changing that behaviour. ([PipeWire][2])

If locking the computer is what triggers it, create this configuration:

```bash
mkdir -p ~/.config/wireplumber/wireplumber.conf.d

cat > ~/.config/wireplumber/wireplumber.conf.d/51-bluez-seat-monitoring.conf <<'EOF'
wireplumber.profiles = {
  main = {
    monitor.bluez.seat-monitoring = disabled
  }
}
EOF

systemctl --user restart wireplumber
```

I would **not apply that yet** unless you notice a clear connection with locking or suspending.

The next time it disconnects, before restarting anything, capture:

```bash
journalctl -b -u bluetooth --since "15 minutes ago"
```

and:

```bash
journalctl --user -b \
  -u wireplumber \
  -u pipewire \
  -u pipewire-pulse \
  --since "15 minutes ago"
```

Those logs should reveal whether the iPad voluntarily disconnected, WirePlumber lost the audio profile, or the Ubuntu Bluetooth adapter reset.

[1]: https://github.com/bluez/bluez/issues/884?utm_source=chatgpt.com "What are the Trusted devices? · Issue #884 · bluez/bluez"
[2]: https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html?utm_source=chatgpt.com "Bluetooth configuration — WirePlumber 0.5.15 ..."

