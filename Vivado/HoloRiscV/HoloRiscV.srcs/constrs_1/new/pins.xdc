## Clock Input
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports CLK100MHZ]

## Pmod Header JA
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports ja_cs]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports ja_mosi]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports ja_miso]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports ja_sck]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports ja_rst]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports ja_wp]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports ja_hld]

## Reset Pin
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports rst]



