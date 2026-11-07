// Virtual Parameter: pppoeUsername (PPPoE Client Username)

const paths = [
  "InternetGatewayDevice.WANDevice.*.WANConnectionDevice.*.WANPPPConnection.*.Username",
  "Device.PPP.Interface.*.Username"
];

let usernameVal = "N/A";

for (const p of paths) {
  const d = declare(p, {value: Date.now()});
  for (const item of d) {
    if (item.value && item.value[0] && item.value[0] !== "") {
      usernameVal = item.value[0];
      break;
    }
  }
  if (usernameVal !== "N/A") break;
}

return {writable: false, value: [usernameVal, "xsd:string"]};
