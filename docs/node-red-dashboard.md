# Node-RED Dashboard Guide

This file explains how to import, deploy, and extend the provided `factory-iiot-flow.json`.

## 1. Import the flow

1. Start Node-RED locally (`npx node-red` or Docker container).
2. Browse to `http://localhost:1880` → menu (☰) → _Import_ → _Select a file_.
3. Choose `flows/factory-iiot-flow.json`, keep _Import to new flow_ checked, and click _Import_.
4. Open the new tab named **Factory IIoT**; verify nodes show no configuration errors (red triangles).

## 2. Configure the MQTT broker

- Double-click the `ChirpStack uplinks` node.
- Edit the broker config if your Mosquitto instance is not on `localhost:1883` or if it requires credentials/TLS.
- Deploy the flow; the MQTT status dot should turn green once it connects.

## 3. Dashboard widgets

The flow already defines a dashboard tab `Factory floor` with three groups:

1. **Machine health** – gauges for temperature, humidity, and vibration.
2. **Trends** – multi-series line chart plotting every sensor using `msg.topic` as the legend label.
3. **Latest readings** – rolling text widgets showing the last timestamped message per sensor.

Access the dashboard at `http://localhost:1880/ui` after deploying.

## 4. Alarm path

- Function `High-temp alarm` filters messages where `sensor` contains `temp` and `value > 60`.
- Matching payloads trigger a toast notification (`Temp > 60°C`) and a Debug sidebar log.
- To add email/SMS, connect the alarm output to the relevant Node-RED nodes (e.g., `e-mail`, `twilio`).

## 5. Extending the flow

- **Additional sensors** – Update the switch node to add a new rule, then duplicate one gauge/text pair.
- **Persistent storage** – Wire the decoded payload to `influxdb out` or `postgres` nodes for history.
- **Advanced analytics** – Insert a `function` node before the chart to calculate rolling averages or anomaly scores.
- **Access control** – Secure the dashboard via `settings.js` (adminAuth) or host Node-RED behind a reverse proxy (Nginx, Traefik).

With these steps, the Node-RED portion of the project will visualize the simulated LoRaWAN telemetry end-to-end.
