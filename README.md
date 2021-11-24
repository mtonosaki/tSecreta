# tSecreta (Swift Version)
Private Password Manager developped with Swift for iOS project. This manager can syncronize secret data to Azure Blob Storage. To specify user account, tSecret use Azure Active Directory authentication.

![64](https://user-images.githubusercontent.com/34669114/143222587-1ed45429-32f7-43e1-aaab-f4e958a17429.png)


## To use this repository, follow step below.


1. Clone this repository to your local environment.
1. Build the swift project with xcode on your mac.


## Azure Active Directory settings

1. App Registration  
Go to "Azure Portal" --> "Active Directory Tenant" --> App registrations
![](https://aqtono.com/tomarika/tsecret/ad01.png)  
Input application name and register.  
![](https://aqtono.com/tomarika/tsecret/ad02.png)  
1. Configure platform  
Select "Authentication" page then add new platform as "Mobile and desktop applications".  
![](https://aqtono.com/tomarika/tsecret/ad03.png)  
...Need two redirect URLs.  
![](https://aqtono.com/tomarika/tsecret/ad04.png)  
1. Get Client ID for your **MySecretParameter.AzureADClientId** value.
![](https://aqtono.com/tomarika/tsecret/ad05.png)  

