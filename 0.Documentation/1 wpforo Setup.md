# Wpforo Setup

In this documentation, I will try to explain how to setup your WpForo while my Wpforo version is 2.4.0 and my WP version is 6.6.2


## Basic Of Wpforo

After installing wpForo, WordPress will automatically create a page called **Forum**. This page is ready to display your forum with wpForo. To show the forum on any page, simply add [wpforo] in a block, and the forum will appear.

For more customization options, go to wpForo Settings in your dashboard. We’ll cover these settings in the next steps. As you can see in picture below:

![Wpforo Basic Setup](./images/wpforo%20basic%20setup.png)

## Fixing the 404 Error in wpForo

If you encounter a 404 error when clicking on any wpForo section, it’s likely due to a conflict between your `web.config` file and wpForo’s default settings.
![404 error in wpforo](./images/404%20error%20in%20wpforo.png)


- Problem Description:  
When this error occurs, you’ll see "index.php" included in the URL (e.g., `yourwebsite/index.php/community`). This extra “index.php” is causing the issue.

- Solution:

1. Edit the `web.config` File:
   - Open the `web.config` file located in the root folder of your website.
   - Add the following code to enable URL rewriting:

   ```xml
   <rewrite>
       <rules>
           <rule name="WordPress Rule" stopProcessing="true">
               <match url=".*" />
               <conditions>
                   <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                   <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
               </conditions>
               <action type="Rewrite" url="index.php/{R:0}" />
           </rule>
       </rules>
   </rewrite>
   ```

2. Install URL Rewrite Module on IIS:
   - If you don’t already have the rewrite module installed on IIS, download and install it using these links:
     - [Rewrite for 64-bit](https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi)
     - [Rewrite for 32-bit](https://download.microsoft.com/download/D/8/1/D81E5DD6-1ABB-46B0-9B4B-21894E18B77F/rewrite_x86_en-US.msi)

3. Set Permalinks in WordPress:

    - In your WordPress dashboard, go to Settings > Permalinks.
    - Select the Post name option, then click Save Changes to ensure URLs work correctly.

This should resolve the 404 error and ensure wpForo works correctly on your site.


## Fixing Image Embedding Issue in wpForo

When posting an embedded image in wpForo, the image is initially embedded using the base64 method, which is correct. As you can see below:
![embedded image base64 problem](./images/embedded%20image%20base64%20problem.png)

![embedded image base64 source code before posting](./images/embedded%20image%20base64%20source%20code%20before%20posting.png)

However, after posting, the `src` attribute loses the "data" part (e.g., `src="data:image/jpeg;base64..."`), causing the image not to show up in the forum post.

![embedded image base64 source code after posting](./images/embedded%20image%20base64%20source%20code%20after%20posting.png)

![embedded image base64 wrong result](./images/embedded%20image%20base64%20wrong%20result.png)

Solution:

1. Access `functions.php`:
   - In your WordPress dashboard, go to **Appearance > Theme Editor**.
   - In the right-hand sidebar, find and click on **functions.php** (usually labeled **Theme Functions**).

2. Add the Fix:
   - Copy and paste the following code into the `functions.php` file:

   ```php
   add_filter('kses_allowed_protocols', function ($protocols) {
       $protocols[] = 'data';

       return $protocols;
   });
   ```

3. Save Changes:
   - After adding the code, click **Update File** to save the changes.

This code allows the `data` protocol in the image source and ensures that embedded images are displayed correctly in your forum posts.

![embedded image base64 corrected version](./images/embedded%20image%20base64%20corrected%20version.png)


## Enable Embedded Attachments in wpForo

When you upload an attachment to a post, you may want it to display as an embedded image or file directly in your post. To enable this feature, follow these steps:

- Solution:

1. **Access `functions.php`**:
   - In your WordPress dashboard, go to **Appearance > Theme Editor**.
   - In the right-hand sidebar, click on **functions.php** (usually labeled **Theme Functions**).

2. **Add the Code**:
   - Copy and paste the following code into the `functions.php` file:

   ```php
   add_filter('wpforo_content_after', function( $content ){
       return preg_replace_callback(
           '#<a[^><]*\sclass=[\'\"](?:[^\'\"]*\s)?wpforo-default-attachment(?:\s[^\'\"]*)?[\'\"][^><]*\shref=[\'\"]([^\"\']+)[\'\"][^><]*>.*?</a>#isu',
           function( $match ){
               $html     = $match[0];
               $file     = $match[1];
               $pathinfo = pathinfo( $file );
               if( wpforo_is_image($pathinfo['extension']) ) {
                   $html = sprintf(
                       '<a href="%1$s" target="_blank"><img class="wpforo-default-image-attachment" src="%1$s" alt="%2$s" title="%2$s"></a>',
                       esc_url($file),
                       esc_attr($pathinfo['basename'])
                   );
               }
               return $html;
           },
           $content
       );
   }, 11);

   add_filter('wpforo_content_after', 'wpforo_default_attachment_image_embed', 11);
   function wpforo_default_attachment_image_embed( $content ){
       if( preg_match_all('|<a class=\"wpforo\-default\-attachment\" href\=\"([^\"\']+)\"[^><]*>.+?<\/a>|is', $content, $data, PREG_SET_ORDER) ){
           foreach($data as $array){
               if(isset($array[1])){
                   $file = $array[1];
                   $e = strtolower(substr(strrchr($file, '.'), 1));
                   if( $e === 'jpg' || $e === 'jpeg' || $e === 'png' || $e === 'gif' || $e === 'bmp' || $e === 'webp' ){
                       $filename = explode('/', $file); $filename = end($filename);
                       $html = '<a href="' . esc_url($file) . '" target="_blank"><img class="wpforo-default-image-attachment" src="' . esc_url($file) . '" alt="' . esc_attr($filename) . '" title="' . esc_attr($filename) . '" /></a>';
                       $content = str_replace($array[0], $html, $content);
                   }
               }
           }
       }
       return $content;
   }
   ```

3. **Save Changes**:
   - After adding the code, click **Update File** to save the changes.

**What This Code Does**:
- The code enables embedded attachments (like images) directly in your forum posts.
- It ensures that image files (JPG, JPEG, PNG, GIF, BMP, and WebP) uploaded to a post are displayed as embedded images, instead of just a downloadable link.

Now, your uploaded images will appear as embedded attachments in the post.