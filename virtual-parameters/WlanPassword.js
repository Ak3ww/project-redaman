// Virtual Parameter: WlanPassword (Primary Wi-Fi Password / KeyPassphrase)

const paths = [
  "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.KeyPassphrase",
  "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.KeyPassphrase",
  "Device.WiFi.AccessPoint.1.Security.KeyPassphrase"
];

let pwd = "N/A";
for (const p of paths) {
  const d = declare(p, {value: Date.now()});
  if (d.value && d.value[0]) {
    pwd = d.value[0];
    break;
  }
}

return {writable: false, value: [pwd, "xsd:string"]};
