# PHP Installation using IIS

In this readme file I want to show step by step of PHP Installation using IIS
*** please note that any changes in configs need and a restart in IIS:
cmd line:
````
iisreset
````

## IIS

1. Open Control Panel:
    - Press Windows + R, type control, and hit Enter.

2. Navigate to Programs:
    - Click on Programs.
    - Then click on Turn Windows features on or off.

3. Enable Internet Information Services (IIS):
    - In the Windows Features dialog, find Internet Information Services.
    - Check the box next to Internet Information Services.
    - Expand the tree under IIS, and ensure the following features are checked:
        -Web Management Tools:
            -IIS Management Console
        -World Wide Web Services:
            -Application Development Features (check the following):
                -.NET Extensibility
                -ASP.NET
                -ISAPI Extensions
                -ISAPI Filters
            -Common HTTP Features
            -Security
            -Performance Features
            -Static Content

    - Enable CGI under IIS:
        - In the Windows Features dialog, scroll down and expand the Internet Information Services node.
        - Expand the World Wide Web Services section.
        - Under Application Development Features, find and check CGI. This will install both CGI and FastCGI.
        - Click OK and wait for Windows to install the CGI and FastCGI components.

    - Verify FastCGI Installation:
        - Open IIS Manager (inetmgr in the Run dialog).
        - Under your server, you should now see FastCGI Settings in the IIS panel.
    - Click OK to install the selected features.

4. Wait for Installation:
    - Windows will install IIS and the selected components. This may take a few minutes.

5. Verify IIS Installation:
    - Once the installation is complete, open a web browser and type http://localhost.
    - You should see the default IIS welcome page, indicating that IIS is successfully installed.

6. Set Correct Permissions

    - Make sure that the IIS user has permission to access the C:\inetpub\wwwroot directory:
        - Right-click on the wwwroot folder, and select Properties.
        - Go to the Security tab.
        - Click Edit, then Add.
        - Enter IIS_IUSRS and click Check Names to validate it.
        - Click OK, and then grant Read & Execute permissions to this user.    


## PHP

1. Download PHP:

    - Go to the [PHP for Windows](https://windows.php.net/download/) website and download the latest non-thread-safe version of PHP (e.g., php-8.x.x-Win32-vs16-x64.zip).

2. Extract PHP Files:

    - Extract the downloaded ZIP file to a directory (e.g., C:\PHP).

3. Configure PHP in IIS:

    - Open the IIS Manager (type inetmgr in the Run dialog).
    - In the Connections pane, select your server (the top node).
    - In the middle pane, double-click on Handler Mappings.
    - On the right pane, click Add Module Mapping.
        - Request Path: *.php
        - Module: FastCgiModule
        - Executable: C:\PHP\php-cgi.exe (adjust the path if you extracted PHP somewhere else)
        - Name: PHP_via_FastCGI
    - Click OK, then confirm by clicking Yes when prompted.

4. Add PHP to Environment Variables:

    - Right-click on This PC and select Properties.
    - Click on Advanced system settings.
    - In the System Properties window, click on the Environment Variables button.
    - Under System variables, find the variable named Path and select it, then click Edit.
    - Click New and add the path to your PHP installation (e.g., C:\PHP).
    - Click OK to close all dialog boxes.

5. Add index.php to Default Documents in IIS:

    - Open IIS Manager (inetmgr).
    - In the Connections pane, select your website (e.g., YourWordPressSite).
    - In the middle pane, double-click on Default Document.
    - In the Actions pane on the right, click Add.
    - Enter index.php and click OK.
    - Ensure index.php is listed at the top or near the top of the default documents list.

6. Test PHP Installation:

    - Create a new file called info.php in the default web directory (usually C:\inetpub\wwwroot).
    - Open Notepad and add the following code:
    
```
<?php
phpinfo();
?>
```
Save the file as info.php.
Open a web browser and navigate to http://localhost/info.php.
You should see the PHP information page.


### Configure FastCGI for PHP

Once you have the FastCGI module installed, you can proceed with configuring PHP in IIS:

- Add PHP to IIS:
    - Open IIS Manager.
    - Click on your server name in the left pane (under Connections).
    - In the middle pane, double-click on Handler Mappings.
    - On the right pane, click Add Module Mapping.
        - Request Path: *.php
        - Module: FastCgiModule
        - Executable: Path to your PHP installation’s php-cgi.exe (e.g., C:\PHP\php-cgi.exe).
        - Name: PHP_via_FastCGI
    - Click OK and confirm the prompt.


### php.ini

1. Locate the Correct php.ini File

    - Check the PHP Installation Directory:
        - Go to the folder where PHP is installed. This is typically something like C:\PHP or C:\Program Files\PHP.
        - Look for a file named php.ini or a sample configuration file named php.ini-development or php.ini-production.

    - If No php.ini File Exists:
        - If you don't see a php.ini file, copy either php.ini-development or php.ini-production and rename the copy to php.ini.

2. Configure IIS to Load the Correct php.ini File

    - Set the Path to the php.ini in IIS:
        - Open IIS Manager (inetmgr).
        In the Connections pane, select your server (the root node).
        - In the middle pane, double-click on PHP Manager (if you don’t see it, you might need to install it via Web Platform Installer or manually).
        - In PHP Manager, click Check phpinfo() to see the current PHP configuration.
        - Ensure that the Configuration File path points to the correct php.ini file.
    - Manually Add Path to php.ini (If Needed):
        - Open the Windows Control Panel.
        - Go to System > Advanced system settings > Environment Variables.
        - In the System variables section, find the variable called PHPRC. If it does not exist, click New and set:
            - Variable name: PHPRC
            - Variable value: The path to your PHP directory (e.g., C:\PHP).
        - This will tell IIS where to find the php.ini file.
    - Check php.ini for Correct Extension Directory:

        - Open your php.ini file and check the extension_dir directive. This should point to the directory where the PHP extensions are located.
        - Look for a line like this:
        ```
        extension_dir = "ext"
        ```
        - If you have PHP installed in C:\Program Files\php\, then you may need to specify the full path:
        ```
        extension_dir = "C:\Program Files\php\ext"
        ```
3. Verify the php.ini File is Loaded

    - Restart IIS:
        - Open IIS Manager.
        - In the Actions pane, click Restart.

    - Check phpinfo() Again:
        - Open an info.php in your browser.
        - Verify that the Configuration File (php.ini) Path now shows the correct path (e.g., C:\PHP\php.ini).

4. Enable mysqli Extension

    - Open php.ini and Enable the mysqli Extension:
        - After ensuring that PHP is loading the correct php.ini file, open the php.ini file in a text editor.
        - Find the following line:

        ```
        ;extension=mysqli
        ;extension=pdo_mysql
        ;extension=mbstring
        ```

    - Remove the semicolon (;) to uncomment the line:
        ```
        extension=mysqli
        extension=pdo_mysql
        extension=mbstring
        ```
        - Save the file.

    - Restart IIS Again:
        - After making changes to php.ini, restart IIS to apply the changes.

5. Verify mysqli is Loaded

    - Check phpinfo() Once Again:
        - Reload info.php.
        - Search for the mysqli extension to confirm it is enabled and loaded.

    