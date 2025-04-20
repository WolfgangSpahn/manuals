# 1. **Install Nginx**

First, ensure that Nginx is installed on your AWS instance. You can install it using:

```bash
sudo apt-get update
sudo apt-get install nginx
```

# 2. **Configure Waitress to Serve the Applications**

Each Flask application should be run by Waitress, bound to a different port on localhost. For example:

## **App 1 (Bound to Port 8001):**

```python
from waitress import serve
from your_flask_app_1 import app

if __name__ == "__main__":
    serve(app, host='127.0.0.1', port=8001)
```

## **App 2 (Bound to Port 8002):**

```python
from waitress import serve
from your_flask_app_2 import app

if __name__ == "__main__":
    serve(app, host='127.0.0.1', port=8002)
```

# 3. **Configure Nginx**

Edit the Nginx configuration file, typically located at `/etc/nginx/sites-available/default` or create a new configuration file for your site under `/etc/nginx/sites-available/`.

Here’s an example configuration:

```nginx
server {
    listen 80;

    server_name your_domain_or_ip;

    location /app1/ {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /app2/ {
        proxy_pass http://127.0.0.1:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

In this configuration:

- Requests to `http://your_domain_or_ip/app1/` will be forwarded to the Flask application running on port `8001`.
- Requests to `http://your_domain_or_ip/app2/` will be forwarded to the Flask application running on port `8002`.

# 4. **Enable the Nginx Configuration**

If you created a new configuration file, you need to enable it by creating a symbolic link to the `sites-enabled` directory:

```bash
sudo ln -s /etc/nginx/sites-available/your_config_file /etc/nginx/sites-enabled/
```

Then, test the Nginx configuration:

```bash
sudo nginx -t
```

If the test is successful, restart Nginx to apply the changes:

```bash
sudo systemctl restart nginx
```

# 5. **Access Your Applications**

You can now access your Flask applications via:

- `http://your_domain_or_ip/app1/` for the first application.
- `http://your_domain_or_ip/app2/` for the second application.

# 6. **Consider SSL (Optional but Recommended)**

If you're exposing these applications publicly, it's highly recommended to use SSL. You can obtain and install a free SSL certificate from Let's Encrypt.

Use the following commands to install Certbot and obtain an SSL certificate:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx
```

Follow the prompts to set up SSL, and Certbot will automatically configure Nginx for HTTPS.

# Summary

This setup allows you to run multiple Flask applications on a single AWS instance using Nginx as a reverse proxy, directing traffic to the appropriate application based on the request URL.

# 7. Trouble shooting

If you don't have the `/etc/nginx/sites-available` and `/etc/nginx/sites-enabled` directories, you can still configure Nginx directly by editing the main `nginx.conf` file or by creating a custom configuration file in the `/etc/nginx/conf.d/` directory. Here's how you can proceed:

### 1. **Edit the `nginx.conf` File or Create a New Configuration**

You can either edit the existing `nginx.conf` file or create a new file within the `conf.d` directory.

#### Option 1: **Edit `nginx.conf`**

Open the main Nginx configuration file:

```bash
sudo nano /etc/nginx/nginx.conf
```

Look for the `http { ... }` block, and inside that block, you can add your server configuration directly.

#### Option 2: **Create a New Configuration File in `conf.d`**

It's often cleaner to create a new configuration file in the `conf.d` directory. For example:

```bash
sudo nano /etc/nginx/conf.d/flask_apps.conf
```

### 2. **Add Your Configuration**

Whether you're editing `nginx.conf` or a new file in `conf.d`, you can use the following example configuration:

```bash
server {
    listen 80;

    server_name your_domain_or_ip;

    location /app1/ {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /app2/ {
        proxy_pass http://127.0.0.1:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. **Test and Restart Nginx**

After adding the configuration, test it to ensure there are no syntax errors:

```bash
sudo nginx -t
```

If the test is successful, restart Nginx to apply the changes:

```bash
sudo systemctl restart nginx
```

### 4. **Access Your Applications**

You can now access your Flask applications as described earlier:

- `http://your_domain_or_ip/app1/` for the first application.
- `http://your_domain_or_ip/app2/` for the second application.

### 5. **Consider SSL (Optional)**

If you want to secure your applications with SSL, you can follow the same steps as mentioned previously to use Let's Encrypt and Certbot to obtain and configure an SSL certificate.

### Summary

In this setup, you're either editing the main `nginx.conf` or creating a new configuration file in `/etc/nginx/conf.d/` to handle your Flask applications. This approach allows you to run multiple applications on different paths using Nginx as a reverse proxy.
