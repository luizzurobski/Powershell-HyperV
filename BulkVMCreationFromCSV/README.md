1. Create your custom image as a VHDX file;
2. Save it in your images folder, e.g. C:\Images;
3. Fill in the .csv file with the image name and configuration for each VM.

Example:  (\n) New-BulkVMCreationLZ -csvFilePath "C:\Scripts\VMConfigurations.csv" -ImagePath "C:\Images"
