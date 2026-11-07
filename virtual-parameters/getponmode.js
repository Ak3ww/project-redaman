// Virtual Parameter: getponmode (GPON vs EPON mode)

let mode = "GPON";
const gpon = declare("InternetGatewayDevice.WANDevice.*.WANGponInterfaceConfig.*", {path: 1});
let foundGpon = false;
for (const p of gpon) {
  foundGpon = true;
  break;
}

if (!foundGpon) {
  const epon = declare("InternetGatewayDevice.WANDevice.*.WANEponInterfaceConfig.*", {path: 1});
  for (const p of epon) {
    mode = "EPON";
    break;
  }
}

return {writable: false, value: [mode, "xsd:string"]};
