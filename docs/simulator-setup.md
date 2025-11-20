# LWN Simulator Configuration Guide

This guide explains how to configure the UniCT LWN Simulator so it behaves like three industrial sensors connected through a single virtual LoRa gateway.

## 1. Install & launch

1. Download the latest release at <https://github.com/UniCT-ARSLab/LWN-Simulator/releases> (Windows `.msi`).
2. Install the simulator (Java 11+ required). Launch it **as Administrator** so the gateway can bind to UDP port 1700.
3. When prompted for workspace, accept the default or create `C:\LWN-Sim`.

## 2. Create the gateway

1. Open the **Gateway** tab and click **Add**.
2. Use the following settings:
   - `Gateway ID`: `AA555A0000000001`
   - `Frequency plan`: `EU868` (matches the default ChirpStack profile; choose a plan compatible with your region).
   - `Server address`: `127.0.0.1`
   - `Server port`: `1700`
3. Save the gateway and ensure the status LED is green.

## 3. Define virtual sensors

Add three devices under the **Device** tab. All devices use OTAA.

| Sensor            | DevEUI             | AppEUI             | AppKey                             | Notes                         |
| ----------------- | ------------------ | ------------------ | ---------------------------------- | ----------------------------- |
| Machine1-Temp     | `70B3D57ED0050101` | `0000000000000001` | `88C96D7D0CE7F6A75E3F4B07D2F74B01` | Sends °C between 40 – 80      |
| Machine1-Humidity | `70B3D57ED0050102` | `0000000000000001` | `43D4C8E8185C0ACD3D39F2C8450AE904` | Sends %RH between 30 – 70     |
| Machine1-Vibe     | `70B3D57ED0050103` | `0000000000000001` | `5E4AEDD6AA9414F068C2E9A6D73B781E` | Sends mm/s RMS between 0 – 30 |

Suggested transmission interval: 30 seconds.

## 4. Encode payloads

Use the simulator's **Application** tab to send JSON objects encoded as Base64. Example JavaScript encoder:

```javascript
function buildPayload(meta) {
  const payload = {
    sensor: meta.sensor,
    value: meta.value,
    unit: meta.unit,
    timestamp: new Date().toISOString(),
  };
  return Buffer.from(JSON.stringify(payload)).toString("base64");
}
```

Recommended simulator ranges:

| Sensor            | Unit | Min | Max | Function idea           |
| ----------------- | ---- | --- | --- | ----------------------- |
| Machine1-Temp     | °C   | 45  | 75  | `45 + Math.random()*30` |
| Machine1-Humidity | %RH  | 35  | 65  | `35 + Math.random()*30` |
| Machine1-Vibe     | mm/s | 2   | 18  | `2 + Math.random()*16`  |

## 5. Connect to ChirpStack

1. Start the Docker stack (`docker compose -f infrastructure/docker-compose.yml up -d`).
2. In the ChirpStack UI, create:
   - **Device profile** (LoRaWAN 1.0.3, OTAA, EU868 band).
   - **Application**: `factory-floor`.
   - **Devices**: reuse the DevEUIs & keys from the table above.
3. Watch _Applications → factory-floor → Live device data_ while starting transmissions; you should see join-accept exchanges followed by uplinks every 30 s.

## 6. Troubleshooting

- **No joins**: ensure the simulator gateway server IP matches your host. If running ChirpStack inside WSL/VM, update the IP accordingly.
- **MIC errors**: double-check AppKey copy/paste and that OTAA vs ABP matches.
- **Payload not decoded**: verify the simulator sends Base64 payload containing JSON; ChirpStack passes this to MQTT unchanged, so Node-RED must decode Base64 → JSON (handled in the provided flow).

Once uplinks show up, proceed with the Node-RED integration outlined in the main README.
