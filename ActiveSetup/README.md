# Active Setup

  This script set automates active setup handling during the installation, or uninstallation of a package.
  In times of multi user environments, it is neccessary to build packages that include mechanics to perform post installations for users how are not currently logged on to computers during installations. Even so more than one user can be logged in at the same time, but only one user can perform an installation.
  
  But how can you performe installation actions for currently logged in users, that are not running the installation by them self?
  
  The answer ist active setup. For more information about active setup use the links below. 

  For installing/uninstalling files, or setting/removing registry keys for other users, currently logged in during installation, create your scripts, doing all the needed actions and compile them as exe-files. Name them "Install.exe" and "Unistall.exe".
  Place Install.exe/Uninstall.exe in active setup folder. Active Setup folder must be located under Common Program Files (x86) directory. Username and SID will be passed on the command line for use in your script.
  
  For performing actions, for users not logged in during installation, place your scripts in the same directory, naming them: "ActiveSetupInstall.EXE" and "ActiveSetupUninstall.EXE".
  Use current user context in this script.
  Include the example command line calls below in your package. All neccessarry registry keys for active steup will be created and updated automatically.
  
### Examples 

  ActiveSetup-LocalMachine - GUID $GUID -Vendor "Microsoft" -ProductName ".Net Framework" -Version "x.x.xxxx" -Folder "ActiveSetupFolder" -Method "install"
    
  ActiveSetup-LocalMachine - GUID $GUID -Vendor "Microsoft" -ProductName ".Net Framework" -Version "x.x.xxxx" -Folder "ActiveSetupFolder" -Method "uninstall"   

### Links 
  https://blogs.msdn.microsoft.com/aruns_blog/2011/06/20/active-setup-registry-key-what-it-is-and-how-to-create-in-the-package-using-admin-studio-install-shield/
  https://gallery.technet.microsoft.com/PS2EXE-Convert-PowerShell-9e4e07f1  
