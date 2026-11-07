// Virtual Parameter: TXPower (Transmit Optical Power Multi-Vendor)

const paths = [
  "InternetGatewayDevice.WANDevice.*.X_GponInterafceConfig.TXPower",
  "InternetGatewayDevice.WANDevice.*.X_HW_OpticalTxPower",
  "InternetGatewayDevice.WANDevice.*.WANGponInterfaceConfig.TXPower",
  "InternetGatewayDevice.WANDevice.*.WANEponInterfaceConfig.TXPower",
  "InternetGatewayDevice.WANDevice.*.X_ZTE-COM_WANPONInterfaceConfig.TxPower",
  "InternetGatewayDevice.WANDevice.*.X_FH_OpticalInfo.TxPower",
  "InternetGatewayDevice.WANDevice.*.X_PON_LINK_CFG.TxPower",
  "Device.Optical.Interface.*.TxPower"
];

let txVal = "N/A";

for (const p of paths) {
  const d = declare(p, {value: Date.now()});
  for (const item of d) {
    if (item.value && item.value[0] !== undefined && item.value[0] !== null && item.value[0] !== "") {
      let raw = String(item.value[0]).trim();
      let num = parseFloat(raw.replace(/[^\d.-]/g, ''));
      if (!isNaN(num)) {
        if (num < -100 || num > 100) {
          num = num / 100;
        }
        txVal = num.toFixed(2) + " dBm";
      } else {
        txVal = raw;
      }
      break;
    }
  }
  if (txVal !== "N/A") break;
}

return {writable: false, value: [txVal, "xsd:string"]};
