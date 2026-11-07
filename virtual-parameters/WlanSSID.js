// Virtual Parameter: WlanSSID (Primary 2.4GHz Wi-Fi SSID)

const paths = [
  "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID",
  "Device.WiFi.SSID.1.SSID"
];

let ssid = "N/A";
for (const p of paths) {
  const d = declare(p, {value: Date.now()});
  if (d.value && d.value[0]) {
    ssid = d.value[0];
    break;
  }
}

return {writable: false, value: [ssid, "xsd:string"]};
