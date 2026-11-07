// GenieACS Provision Script: default-inform
// Auto-triggered when ONT connects to refresh optical attenuation & status

// Refresh key parameters at inform
declare("InternetGatewayDevice.DeviceInfo.UpTime", {value: 1});
declare("InternetGatewayDevice.WANDevice.*.WANConnectionDevice.*.WANPPPConnection.*.ExternalIPAddress", {value: 1});
declare("InternetGatewayDevice.WANDevice.*.X_GponInterafceConfig.RXPower", {value: 1});
declare("InternetGatewayDevice.WANDevice.*.WANGponInterfaceConfig.RXPower", {value: 1});
declare("InternetGatewayDevice.WANDevice.*.WANEponInterfaceConfig.RXPower", {value: 1});
declare("InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID", {value: 1});
