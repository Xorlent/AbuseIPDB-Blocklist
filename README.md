# AbuseIPDB-Blocklist
Generates a threat feed IP list by querying AbuseIPDB. The output can then be consumed by firewalls and filtering tools.  

## Prerequisites
1. AbuseIPDB subscription (sign up at https://www.abuseipdb.com/pricing)  
2. A Windows machine with PowerShell  
3. A web server where the output files will be copied for your firewal

## Setup and Configuration
1. Save RefreshAbuseIP.ps1 and empty.txt to a folder with write permissions for the AbuseIP batch user account.  
2. Grant write permissions to an internal web host direcory for the AbuseIP batch account.  This is where your firewall will fetch the updated threat feed(s). If you don't need this functionality, you can simply specify a directory where you want the final output files to be saved.  
3. Edit RefreshAbuseIP.ps1 and set $AbuseIPKey and $AbuseIPConfidence values as appropriate.  
4. Set the following values as appropriate  
   - $sourceFile = "C:\Scripts\abuseipdb\abuseipdb.txt" # Output file from the abuseipdb API call
   - $desFolderPathSplitFile = "D:\Block_List\abuseip" # Destination location for the blocklist files
   - $tempFolderPathSplitFile = "C:\Scripts\abuseipdb\" # Working directory for the blocklist files

## Running
1. Execute RefreshAbuseIP.ps1
