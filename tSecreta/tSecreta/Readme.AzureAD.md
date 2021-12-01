https://docs.microsoft.com/ja-jp/azure/active-directory/develop/tutorial-v2-ios

# XCode package import
1. xcode --> File --> Add Packages...
1. input MSAL git URL into [Serch or Enter package URL]
   MSAL URL --> https://github.com/AzureAD/microsoft-authentication-library-for-objc.git
1. select "microsoft-authentication-library-for-objc"
1. Dependency rult : [branch] -- "master"
1. then click [Add package] button

# Add AzureAD applicaiton
1. Open Azure Portal
1. Open Active Directory of your selected tenant
1. Open "App registrations"
1. Tap [+ New registration"
1. Input "tSecreta" as application name
1. Select 
Accounts in any organizational directory and personal Microsoft accounts
1. Tap registory button
1. Open Authentication of the tSecreta application
1. Tap [+ Add a platform]
1. Select [iOS or macOS app]
1. Input bundle id (you can confirm bundle id --> Open XCode --> tap tSecreta in navigator  --> general)


