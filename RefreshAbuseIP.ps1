# Sign up for an AbuseIPDB account here https://www.abuseipdb.com/pricing
$AbuseIPKey = 'EnterAccessKeyHere' # Update this value to your AbuseIP API key.  
$AbuseIPConfidence = '44' # The recommended confidence value (requires a AbuseIPDB Premium license due to > 100,000 IPs returned).  Change to 80 for a basic account.

$sourceFile = "C:\Scripts\abuseipdb\abuseipdb.txt" # Output file from the abuseipdb API call
$desFolderPathSplitFile = "D:\Block_List\abuseip" # Destination location for the blocklist files
$tempFolderPathSplitFile = "C:\Scripts\abuseipdb\" # Working directory for the blocklist files
$emptyFile = "empty" # Firewall is always expecting $maxfiles blocklist files.  If we generate fewer, an empty placeholder file by this name will be copied to the destination
$maxsize = 90000 # The maximum number of lines per file 
$filenumber = 0 # Counter for the number of generated output blocklist files (max 100k per file due to Fortigate limitation)
$linecount = 0 # Keeps track of the current line number during blocklist file generation
$maxfiles = 3 # The is the number of external feeds we have configured for this source.  If we need more, firewall config needs to be configured with more or less external threat feeds to accommodate.

$AbuseIPRequest = 'https://api.abuseipdb.com/api/v2/blacklist?limit=500000&confidenceMinimum='+ $AbuseIPConfidence + '&plaintext&key=' + $AbuseIPKey

rm $sourceFile # Remove the last abuseipdb API call output file

# Call abuseipdb to get a fresh file
curl $AbuseIPRequest -o $sourceFile

# Open the file generated from the API call
$reader = new-object System.IO.StreamReader($sourceFile)

# remove the first blocklist temp file: 0.txt
rm $tempFolderPathSplitFile$filenumber.txt

# start reading in the output from abuseipdb and adding each line to the blocklist files, break at $maxsize
while(($line = $reader.ReadLine()) -ne $null)
{
  Add-Content $tempFolderPathSplitFile$filenumber.txt $line
  $linecount ++
  If ($linecount -eq $maxsize) # If we hit the max line count for a temp output file
  {
    cp $tempFolderPathSplitFile$filenumber.txt $desFolderPathSplitFile$filenumber.txt # Copy the generated file to the web directory for pickup by Fortigate
    $filenumber++ # Increment the file number
    rm $tempFolderPathSplitFile$filenumber.txt # Remove any prior temp file with the same name and the next blocklist file we'll be generating
    $linecount = 0 # Reset temp output file line count to 0
  }
}
# Cleanly close the file handle for the API call data we read in
$reader.Close()
$reader.Dispose()

# Copy the final file (this would be the one with size < $maxsize) to the web directory for pickup by Fortigate
cp $tempFolderPathSplitFile$filenumber.txt $desFolderPathSplitFile$filenumber.txt

$filenumber++ # Increment the file number

while($filenumber -lt $maxfiles) # If the total returned results fits in less than three block files, we need to drop an empty file for the remaining ones (ex: abuseip2.txt) so they do not contain stale data
{
  cp $tempFolderPathSplitFile$emptyFile.txt $desFolderPathSplitFile$filenumber.txt # Copy the empty file to the web directory for pickup by Fortigate
  $filenumber++ # Increment the file number
}
