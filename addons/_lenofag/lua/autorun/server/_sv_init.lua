print("INIT SCRIPT STARTED\n")
require "xterm"
MsgC(Color(0, 255, 0), "gm_xterm loaded...\n")

require "serversecure"
MsgC(Color(0, 255, 0), "gmsv_serversecure loaded...\n")

serversecure.EnableFileValidation(true)
serversecure.EnablePacketValidation(true)

serversecure.EnableInfoCache(true)
serversecure.SetInfoCacheTime(5)

serversecure.EnableQueryLimiter(true)

require("network")
MsgC(Color(0, 255, 0), "gmsv_network loaded... uwu klenya\n")
