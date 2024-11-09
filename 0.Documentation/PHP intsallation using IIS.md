# PHP Installation using IIS

In this readme file I want to show step by step of PHP Installation using IIS

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

5. Test PHP Installation:

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