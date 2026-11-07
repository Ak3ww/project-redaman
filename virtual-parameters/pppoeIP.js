// Virtual Parameter: pppoeIP (WAN IP / PPPoE IP Address)

const paths = [
  "InternetGatewayDevice.WANDevice.*.WANConnectionDevice.*.WANPPPConnection.*.ExternalIPAddress",
  "InternetGatewayDevice.WANDevice.*.WANConnectionDevice.*.WANIPConnection.*.ExternalIPAddress",
  "Device.IP.Interface.*.IPv4Address.*.IPAddress"
];

let ipVal = "N/A";

for (const p of paths) {
  const d = declare(p, {value: Date.now()});
  for (const item of d) {
    if (item.value && item.value[0] && item.value[0] !== "0.0.0.0" && item.value[0] !== "") {
      ipVal = item.value[0];
      break;
    }
  }
  if (ipVal !== "N/A") break;
}

return {writable: false, value: [ipVal, "xsd:string"]};
