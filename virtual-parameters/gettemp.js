// Virtual Parameter: gettemp (Transceiver Temperature)

const paths = [
  "InternetGatewayDevice.WANDevice.*.X_GponInterafceConfig.TransceiverTemperature",
  "InternetGatewayDevice.WANDevice.*.X_HW_TransceiverTemperature",
  "InternetGatewayDevice.WANDevice.*.WANGponInterfaceConfig.TransceiverTemperature",
  "InternetGatewayDevice.WANDevice.*.WANEponInterfaceConfig.TransceiverTemperature",
  "InternetGatewayDevice.WANDevice.*.X_ZTE-COM_WANPONInterfaceConfig.Temperature",
  "Device.Optical.Interface.*.TransceiverTemperature"
];

let tempVal = "N/A";

for (const p of paths) {
  const d = declare(p, {value: Date.now()});
  for (const item of d) {
    if (item.value && item.value[0] !== undefined && item.value[0] !== null && item.value[0] !== "") {
      let raw = String(item.value[0]).trim();
      let num = parseFloat(raw.replace(/[^\d.-]/g, ''));
      if (!isNaN(num)) {
        if (num > 1000) num = num / 1000;
        else if (num > 200) num = num / 100;
        tempVal = Math.round(num) + " °C";
      } else {
        tempVal = raw;
      }
      break;
    }
  }
  if (tempVal !== "N/A") break;
}

return {writable: false, value: [tempVal, "xsd:string"]};
