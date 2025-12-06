//+------------------------------------------------------------------+
//|                                          SkyCoreUniverseAPI.mqh  |
//|                      Copyright © 2025 Pixels of Midnight         |
//|                                                                  |
//| Backend Communication Module for SkyCore Universe Platform      |
//| Handles: License validation, session management, trade reporting|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2025 Pixels of Midnight"
#property strict

//+------------------------------------------------------------------+
//| UNIVERSE API Configuration                                        |
//+------------------------------------------------------------------+

// Global variables for Universe backend communication
string G_supabaseURL = "";
string G_supabaseKey = "";
string G_licenseKey = "";
string G_userEmail = "";
string G_sessionID = "";
string G_accountID = "";
string G_userID = "";
datetime G_lastHeartbeat = 0;
int G_heartbeatInterval = 300; // 5 minutes in seconds
bool G_licenseValid = false;
string G_robotName = "Hydra"; // Will be set per EA

//+------------------------------------------------------------------+
//| Helper: Build JSON string (simple, no library needed)            |
//+------------------------------------------------------------------+
string JsonString(string key, string value)
{
   return "\"" + key + "\":\"" + value + "\"";
}

string JsonNumber(string key, double value, int digits = 2)
{
   return "\"" + key + "\":" + DoubleToString(value, digits);
}

string JsonInt(string key, int value)
{
   return "\"" + key + "\":" + IntegerToString(value);
}

string JsonBool(string key, bool value)
{
   return "\"" + key + "\":" + (value ? "true" : "false");
}

string JsonDatetime(string key, datetime value)
{
   string iso = TimeToString(value, TIME_DATE|TIME_SECONDS);
   StringReplace(iso, ".", "-");
   StringReplace(iso, " ", "T");
   return "\"" + key + "\":\"" + iso + "Z\"";
}

//+------------------------------------------------------------------+
//| Helper: Send HTTP POST request to Supabase                       |
//+------------------------------------------------------------------+
bool SendPostRequest(string endpoint, string jsonBody, string &response)
{
   string url = G_supabaseURL + endpoint;
   string headers = "Content-Type: application/json\r\n";
   headers += "apikey: " + G_supabaseKey + "\r\n";
   headers += "Prefer: return=representation\r\n";

   char post[], result[];
   StringToCharArray(jsonBody, post, 0, StringLen(jsonBody));

   ResetLastError();
   int res = WebRequest("POST", url, headers, 5000, post, result, headers);

   if(res == -1)
   {
      int error = GetLastError();
      Print("❌ WebRequest Error: ", error, " - ", ErrorDescription(error));
      Print("⚠️ Make sure URL is in allowed list: Tools → Options → Expert Advisors → Allow WebRequest for: ", G_supabaseURL);
      return false;
   }

   response = CharArrayToString(result);

   if(res != 200 && res != 201)
   {
      Print("❌ HTTP Error ", res, ": ", response);
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Helper: Send HTTP PATCH request to Supabase                      |
//+------------------------------------------------------------------+
bool SendPatchRequest(string endpoint, string jsonBody, string &response)
{
   string url = G_supabaseURL + endpoint;
   string headers = "Content-Type: application/json\r\n";
   headers += "apikey: " + G_supabaseKey + "\r\n";
   headers += "Prefer: return=representation\r\n";

   char post[], result[];
   StringToCharArray(jsonBody, post, 0, StringLen(jsonBody));

   ResetLastError();
   int res = WebRequest("PATCH", url, headers, 5000, post, result, headers);

   if(res == -1)
   {
      Print("❌ WebRequest Error: ", GetLastError());
      return false;
   }

   response = CharArrayToString(result);

   if(res != 200 && res != 204)
   {
      Print("❌ PATCH Error ", res, ": ", response);
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Validate License with Backend                                    |
//+------------------------------------------------------------------+
bool ValidateLicense(string pLicenseKey, long accountNumber)
{
   Print("🔐 Validating license with SkyBot Universe...");

   string jsonBody = "{" +
      JsonString("p_license_key", pLicenseKey) + "," +
      JsonNumber("p_account_number", (double)accountNumber, 0) +
   "}";

   string response;
   if(!SendPostRequest("/rest/v1/rpc/validate_license", jsonBody, response))
   {
      Print("❌ License validation failed - No response from server");
      return false;
   }

   // Parse response (simple string search, no JSON library)
   if(StringFind(response, "\"valid\":true") >= 0)
   {
      // Extract user_id
      int uidPos = StringFind(response, "\"user_id\":\"");
      if(uidPos >= 0)
      {
         uidPos += 12; // Skip "user_id":"
         int uidEnd = StringFind(response, "\"", uidPos);
         G_userID = StringSubstr(response, uidPos, uidEnd - uidPos);
      }

      // Extract account_id
      int aidPos = StringFind(response, "\"account_id\":\"");
      if(aidPos >= 0)
      {
         aidPos += 15;
         int aidEnd = StringFind(response, "\"", aidPos);
         G_accountID = StringSubstr(response, aidPos, aidEnd - aidPos);
      }

      Print("✅ License valid! User ID: ", G_userID);
      Print("✅ Account ID: ", G_accountID);
      return true;
   }
   else
   {
      Print("❌ Invalid license or expired");
      // Extract error message
      int errPos = StringFind(response, "\"error\":\"");
      if(errPos >= 0)
      {
         errPos += 9;
         int errEnd = StringFind(response, "\"", errPos);
         string errorMsg = StringSubstr(response, errPos, errEnd - errPos);
         Print("❌ Error: ", errorMsg);
      }
      return false;
   }
}

//+------------------------------------------------------------------+
//| Start Robot Session                                              |
//+------------------------------------------------------------------+
bool StartSession(string robotName, string robotVersion, int magicNumber)
{
   Print("🚀 Starting ", robotName, " session...");

   string cloudInstance = "hetzner-" + IntegerToString(MathRand() % 100 + 1);

   string jsonBody = "{" +
      JsonString("mt4_account_id", G_accountID) + "," +
      JsonString("user_id", G_userID) + "," +
      JsonString("robot_name", robotName) + "," +
      JsonString("robot_version", robotVersion) + "," +
      JsonString("cloud_instance_id", cloudInstance) + "," +
      JsonInt("ea_magic_number", magicNumber) + "," +
      JsonString("status", "active") +
   "}";

   string response;
   if(!SendPostRequest("/rest/v1/robot_sessions", jsonBody, response))
   {
      Print("❌ Failed to start session");
      return false;
   }

   // Extract session ID
   int sidPos = StringFind(response, "\"id\":\"");
   if(sidPos >= 0)
   {
      sidPos += 6;
      int sidEnd = StringFind(response, "\"", sidPos);
      G_sessionID = StringSubstr(response, sidPos, sidEnd - sidPos);
      Print("✅ Session started! ID: ", G_sessionID);
      return true;
   }

   Print("❌ Could not extract session ID from response");
   return false;
}

//+------------------------------------------------------------------+
//| Send Heartbeat (every 5 minutes)                                 |
//+------------------------------------------------------------------+
void SendHeartbeat(int tradesOpened, int tradesClosed, double currentProfit)
{
   if(G_sessionID == "")
      return;

   // Check if 5 minutes passed
   if(TimeCurrent() - G_lastHeartbeat < G_heartbeatInterval)
      return;

   string endpoint = "/rest/v1/robot_sessions?id=eq." + G_sessionID;

   string jsonBody = "{" +
      JsonDatetime("last_heartbeat", TimeCurrent()) + "," +
      JsonString("status", "active") + "," +
      JsonInt("trades_opened", tradesOpened) + "," +
      JsonInt("trades_closed", tradesClosed) + "," +
      JsonNumber("current_profit_usd", currentProfit, 2) +
   "}";

   string response;
   if(SendPatchRequest(endpoint, jsonBody, response))
   {
      G_lastHeartbeat = TimeCurrent();
      // Print("💓 Heartbeat sent"); // Uncomment for debugging
   }
}

//+------------------------------------------------------------------+
//| Report Trade Opened                                              |
//+------------------------------------------------------------------+
bool ReportTradeOpened(int ticket, string symbol, int orderType, double pLots,
                       double openPrice, double sl, double tp, int magic)
{
   if(G_sessionID == "" || G_userID == "" || G_accountID == "")
      return false;

   string tradeType = (orderType == OP_BUY) ? "BUY" : "SELL";

   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return false;

   string jsonBody = "{" +
      JsonString("session_id", G_sessionID) + "," +
      JsonString("user_id", G_userID) + "," +
      JsonString("mt4_account_id", G_accountID) + "," +
      JsonNumber("ticket_number", (double)ticket, 0) + "," +
      JsonInt("magic_number", magic) + "," +
      JsonString("symbol", symbol) + "," +
      JsonString("trade_type", tradeType) + "," +
      JsonNumber("lot_size", pLots, 2) + "," +
      JsonNumber("open_price", openPrice, 5) + "," +
      JsonNumber("stop_loss", sl, 5) + "," +
      JsonNumber("take_profit", tp, 5) + "," +
      JsonDatetime("open_time", OrderOpenTime()) + "," +
      JsonString("status", "open") +
   "}";

   string response;
   if(SendPostRequest("/rest/v1/trades_log", jsonBody, response))
   {
      Print("📊 Trade #", ticket, " reported to backend");
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Report Trade Closed                                              |
//+------------------------------------------------------------------+
bool ReportTradeClosed(int ticket, double closePrice, double profit,
                       double commission, double swap, string closeReason)
{
   if(G_accountID == "")
      return false;

   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return false;

   string endpoint = "/rest/v1/trades_log?ticket_number=eq." +
                     IntegerToString(ticket) +
                     "&mt4_account_id=eq." + G_accountID;

   string jsonBody = "{" +
      JsonNumber("close_price", closePrice, 5) + "," +
      JsonDatetime("close_time", TimeCurrent()) + "," +
      JsonNumber("profit_usd", profit, 2) + "," +
      JsonNumber("commission", commission, 2) + "," +
      JsonNumber("swap", swap, 2) + "," +
      JsonString("status", "closed") + "," +
      JsonString("close_reason", closeReason) +
   "}";

   string response;
   if(SendPatchRequest(endpoint, jsonBody, response))
   {
      Print("📊 Trade #", ticket, " closed - Reported to backend");
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| End Session (called on EA removal)                               |
//+------------------------------------------------------------------+
void EndSession()
{
   if(G_sessionID == "")
      return;

   Print("🛑 Ending session...");

   string endpoint = "/rest/v1/robot_sessions?id=eq." + G_sessionID;

   string jsonBody = "{" +
      JsonDatetime("session_end", TimeCurrent()) + "," +
      JsonString("status", "inactive") +
   "}";

   string response;
   SendPatchRequest(endpoint, jsonBody, response);

   Print("✅ Session ended");
}

//+------------------------------------------------------------------+
//| Error Description Helper                                         |
//+------------------------------------------------------------------+
string ErrorDescription(int errorCode)
{
   string error = "";
   switch(errorCode)
   {
      case 4060: error = "Function not allowed. Enable WebRequest in MT4 settings"; break;
      case 4014: error = "System is busy"; break;
      case 5203: error = "URL not allowed in WebRequest list"; break;
      default: error = "Error code: " + IntegerToString(errorCode);
   }
   return error;
}
