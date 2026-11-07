// Virtual Parameter: RXPower (Deteksi Redaman Optik Multi-Vendor)
// Supports: Huawei, ZTE, Fiberhome, VSOL, HSGQ, & TR-181 Standard

const paths = [
  "InternetGatewayDevice.WANDevice.*.X_GponInterafceConfig.RXPower",
  "InternetGatewayDevice.WANDevice.*.X_HW_OpticalRxPower",
  "InternetGatewayDevice.WANDevice.*.WANGponInterfaceConfig.RXPower",
  "InternetGatewayDevice.WANDevice.*.WANEponInterfaceConfig.RXPower",
  "InternetGatewayDevice.WANDevice.*.X_ZTE-COM_WANPONInterfaceConfig.RxPower",
  "InternetGatewayDevice.WANDevice.*.X_FH_OpticalInfo.RxPower",
  "InternetGatewayDevice.WANDevice.*.X_PON_LINK_CFG.RxPower",
  "Device.Optical.Interface.*.RxPower"
];

let rxVal = "N/A";

for (const p of paths) {
  const d = declare(p, {value: Date.now()});
  for (const item of d) {
    if (item.value && item.value[0] !== undefined && item.value[0] !== null && item.value[0] !== "") {
      let raw = String(item.value[0]).trim();
      
      // Filter out invalid/zero/dummy values
      if (raw === "0" || raw === "N/A" || raw === "-") continue;
      
      // Parse numeric dBm value if formatted
      let num = parseFloat(raw.replace(/[^\d.-]/g, ''));
      if (!isNaN(num)) {
        // If raw is in 0.01 dBm or 0.1 dBm (e.g. -2350 instead of -23.50)
        if (num < -100 || num > 100) {
          num = num / 100;
        }
        rxVal = num.toFixed(2) + " dBm";
      } else {
        rxVal = raw;
      }
      break;
    }
  }
  if (rxVal !== "N/A") break;
}

return {writable: false, value: [rxVal, "xsd:string"]};
