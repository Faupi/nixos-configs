M140 S60 ; starting by heating the bed for nominal mesh accuracy
M117 Homing all axes ; send message to printer display
G90
G28 X Y Z ; home all axes
M420 S0 ; Turning off bed leveling while probing, if firmware is set to restore after G28
M117 Heating the bed ; send message to printer display
M190 S60 ; waiting until the bed is fully warmed up
M117 Creating the bed mesh levels ; send message to printer display
M155 S30 ; reduce temperature reporting rate to reduce output pollution
@BEDLEVELVISUALIZER ; tell the plugin to watch for reported mesh
G29 T ; run bilinear probing
M155 S3 ; reset temperature reporting
M500 ; store mesh in EEPROM
M117 Bed mesh levels done ; send message to printer display
