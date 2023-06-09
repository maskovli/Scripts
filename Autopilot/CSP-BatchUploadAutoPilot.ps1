# Import Partner Center module
Install-Module PartnerCenter –force -Verbose
Install-Module WindowsAutopilotPartnerCenter –force -Verbose

# Authenticate to Partner Center
Connect-PartnerCenter

# Specify the customer Id, group Tag and csv-path.
$customerId = "5633285f-092f-4734-a031-449f0e1030ad"
$GroupTag = "FO-Project"
$CSVPath = "C:\Temp\Upload.csv"

# Read the CSV file with serial numbers and models
$deviceList = Import-Csv -Path $CSVPath

# Loop through each device
foreach ($device in $deviceList) {

    # Upload the device to the autopilot profile
    Import-AutoPilotPartnerCenterCSV -csvFile $CSVPath-CustomerId $customerId -BatchID $GroupTags
}