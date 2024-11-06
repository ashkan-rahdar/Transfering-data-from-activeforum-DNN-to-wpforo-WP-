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
    - Click OK to install the selected features.

4. Wait for Installation:
    - Windows will install IIS and the selected components. This may take a few minutes.

5. Verify IIS Installation:
    - Once the installation is complete, open a web browser and type http://localhost.
    - You should see the default IIS welcome page, indicating that IIS is successfully installed.