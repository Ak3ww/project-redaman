// Virtual Parameter: getdeviceuptime (ONT Device Uptime formatted)

const d = declare("InternetGatewayDevice.DeviceInfo.UpTime", {value: Date.now()});
let uptimeSeconds = 0;

if (d.value && d.value[0]) {
  uptimeSeconds = parseInt(d.value[0], 10);
}

if (!uptimeSeconds || isNaN(uptimeSeconds)) {
  const d2 = declare("Device.DeviceInfo.UpTime", {value: Date.now()});
  if (d2.value && d2.value[0]) {
    uptimeSeconds = parseInt(d2.value[0], 10);
  }
}

let formatted = "N/A";
if (uptimeSeconds > 0) {
  const days = Math.floor(uptimeSeconds / 86400);
  const hours = Math.floor((uptimeSeconds % 86400) / 3600);
  const mins = Math.floor((uptimeSeconds % 3600) / 60);
  if (days > 0) formatted = days + "d " + hours + "h " + mins + "m";
  else if (hours > 0) formatted = hours + "h " + mins + "m";
  else formatted = mins + "m";
}

return {writable: false, value: [formatted, "xsd:string"]};
