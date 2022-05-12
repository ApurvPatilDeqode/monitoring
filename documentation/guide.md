# **Solution**
We have installed NGINX server on one ubuntu ec2 instance and installed prometheus-nginx-exporter so that it can scrape NGINX specific metrics to prometheus. Also we have implemented node-exporter to keep track of hardware level metrics of ubuntu ec2 instance to keep track of disc , memory usage.
On the other hand, we have installed prometheus server on ubuntu ec2 instance where we have created custom configuration file of prometheus which monitors the NGINX service running on other ubuntu ec2 instance. Over this instance we have also configured grafana server with imported Node_Exporter dashboard which gives elaborative visualization of NGINX server. With alertmanager we have also achieved to recieve email notifications on service failure. 

## 1. NGINX Server:
### The process guides way to 
   - Install NGINX server & configure reverse proxy
   - Install Prometheus Nginx Exporter to scrape NGINX metrics & service for prometheus-node-exporter
   - Install Node Exporter to scrape instance metrics & service for node-exporter
   
## 2. Prometheus Server:
### The process guides way to
   - Install prometheus server & service
   - Install grafana server & service
   - Install alertmanger server & service

#### 1.NGINX Server:
- Create ubuntu ec2 instance with the configurations specified into readme.
- Install the NGINX server as follows
   * Download the NGINX signing key:
   ```
    $ sudo wget http://nginx.org/keys/nginx_signing.key
   ``` 
   * Add the key:
   ```
    $ sudo apt-key add nginx_signing.key
   ```
   * Change directory to /etc/apt.:
   ```
    $ cd /etc/apt
   ```
   * Edit the sources.list file, appending this text at the end:
   ```
    deb http://nginx.org/packages/ubuntu focal nginx
    deb-src http://nginx.org/packages/ubuntu focal nginx
   ```
   **NOTE** The focal keyword in each of these lines corresponds to Ubuntu 20.04. If you are using a different version of Ubuntu, substitute the first word of its release code name (for example, bionic for Ubuntu 18.04).
   * Update the NGINX software:
   ```
    $ sudo apt-get update
   ```
   * Install NGINX:
   ```
    $ sudo apt-get install nginx -y
   ```
   * Start NGINX:
   ```
    $ sudo systemctl start nginx.service
   ```
   * Check its status:
   ```
    $ sudo systemctl status nginx.service
   ```
- Setting up proxy-server
   * Change directory to /etc/nginx/conf.d.
   ```
    $ cd /etc/nginx/conf.d
   ```
   * Update default.conf as mentioned in **nginx-reverse-proxy-configuration

- Setup prometheus-nginx-exporter
   * If you do not want to use one of the pre-built packages, you can download the binary itself and manually configure systemd to start it.
   ```
    $ wget -O /etc/systemd/system/prometheus-nginxlog-exporter.service https://raw.githubusercontent.com/martin-helmich/prometheus-nginxlog-exporter/master/res/package/prometheus-nginxlog-exporter.service

    $ systemctl enable prometheus-nginxlog-exporter

    $ systemctl start prometheus-nginxlog-exporter
   ```
   The shipped unit file expects the binary to be located in **/usr/sbin/prometheus-nginxlog-exporter** (if you sideload the exporter without using your package manager, you might want to put it to /usr/local, instead) and the configuration file in /etc/prometheus-nginxlog-exporter.hcl. Adjust as shown in **prometheus-nginx-logexporter.hcl**
- Install node-exporter over NGINX's instance
   * You need to download the Node Exporter binary
   ```
    $ wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
   ``` 
   * After downloading the latest version of Node Exporter, proceed to extract the content of the downloaded tar using the following command:
   ```
    $ tar xvf node_exporter-1.3.1.linux-amd64.tar.gz
   ```
   * You only need to move the binary file node_exporter to the /usr/local/bin directory of your system. Switch to the node_exporter directory:
   ```
    $ cd node_exporter-1.3.1.linux-amd64
   ```
   * And then copy the binary file with the following command:
   ```
    $ sudo cp node_exporter /usr/local/bin
   ```
   * As a good practice, create an user in the system for Node Exporter:
   ```
    $ sudo useradd --no-create-home --shell /bin/false node_exporter
   ```
   * And set the owner of the binary node_exporter to the recently created user:
   ```
    $ sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
   ```
   * The Node Exporter service should always start when the server boots so it will always be available to be scrapped for information. Create the node_exporter.service file with nano:
   ```
    $ sudo nano /etc/systemd/system/node_exporter.service
   ```
   * Refer **node_exporter.service** file pushed over github.
   * Close nano and save the changes to the file. Proceed to reload the daemon with:
   ```
    $ sudo systemctl daemon-reload
   ```
   * And finally start the node_exporter service with the following command:
   ```
    $ sudo systemctl start node_exporter
   ```
   * access your server through the web browser at port 9100

#### 2. Prometheus Server:
- Create ubuntu ec2 instance with the configurations specified into readme.
- Install prometheus server as follow
   * Start off by updating the package lists as follows:
   ```
    $ sudo apt update
   ```  
   * To create the configuration directory, run the command:
   ```
    $ sudo mkdir -p /etc/prometheus
   ```
   * For the data directory, execute:
   ```
    $ sudo mkdir -p /var/lib/prometheus
   ```
   * Once the directories are created, grab the compressed installation file:
   ```
    $ wget https://github.com/prometheus/prometheus/releases/download/v2.31.0/prometheus-2.31.0.linux-amd64.tar.gz 
   ```
   * Once downloaded, extract the tarball file.
   ```
    $  tar -xvf prometheus-2.31.3.linux-amd64.tar.gz
   ```
   * Then navigate to the Prometheus folder.
   ```
    $ cd prometheus-2.31.3.linux-amd64
   ``` 
   * Once in the directory move the  prometheus and promtool binary files to /usr/local/bin/ folder.
   ```
    $ sudo mv prometheus promtool /usr/local/bin/
   ```
   * Additionally, move console files in console directory and library files in the console_libraries  directory to /etc/prometheus/ directory.
   ```
    $ sudo mv consoles/ console_libraries/ /etc/prometheus/
   ```
   * Also, ensure to move the prometheus.yml template configuration file to the  /etc/prometheus/ directory.
   ```
    $ sudo mv prometheus.yml /etc/prometheus/prometheus.yml
   ```
   * At this point, Prometheus has been successfully installed.
   * It's essential that we create a Prometheus group and user before proceeding to the next step which involves creating a system file for Prometheus.To  create a prometheus group execute the command:
   ```
    $ sudo groupadd --system prometheus
   ```
   * Thereafter, Create prometheus user and assign it to the just-created prometheus group.
   ```
    $ sudo useradd -s /sbin/nologin --system -g prometheus prometheus
   ```
   * Next, configure the directory ownership and permissions as follows.
   ```
    $ sudo chown -R prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/
    $ sudo chmod -R 775 /etc/prometheus/ /var/lib/prometheus/
   ```
   * The only part remaining is to make Prometheus a systemd service so that we can easily manage its running status.Using your favorite text editor, create a systemd service file:
   ```
    $ sudo vim /etc/systemd/system/prometheus.service
   ```
   * Refer the **prometheus.service** pushed over github
   * Then proceed and start the Prometheus service.
   ```
    $ sudo systemctl start prometheus
   ```
   * Enable the Prometheus service to run at startup. Therefore invoke the command:
   ```
    $ sudo systemctl enable prometheus
   ```
   * Then confirm the status of the Prometheus service.
   ```
    $ sudo systemctl status prometheus
   ```
   * Finally, to access Prometheus, launch your browser and visit your server's IP address followed by port 9090.

- Install grafana server & service
   * Grafana is not present in the default repositories of Ubuntu. We will add the official repository of Grafana for the installation. This ensures you have the latest version of it.Run the following commands to add the Grafana repository:
   ```
    $ sudo wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    $ echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
   ```
   * Install the other necessary packages
   ```
    $ sudo apt install -y apt-transport-https software-properties-common wget
   ```
   * Update the cache of the repositories
   ```
    $ sudo apt update
   ```
   * Now you can install Grafana with the APT command
   ```
    $ sudo apt install grafana
   ```
   * You can check the version installed for more information
   ```
    $ grafana-server -v
   ```
   * Now enable the service on startup so that if the server reboot, it will also start automatically
   ```
    $ sudo systemctl enable grafana-server
   ```
   * You need to start the service for Grafana to work properly
   ```
    $ sudo systemctl start grafana-server
   ```
- Install alertmanager server & service:
   * Download the version of Alert Manager (v0.22.2 at the time of this writing) with the following command:
   ```
    $ wget https://github.com/prometheus/alertmanager/releases/download/v0.22.2/alertmanager-0.22.2.linux-amd64.tar.gz
   ```
   * Once Alert Manager is downloaded, you should find a new archive file alertmanager-0.22.2.linux-amd64.tar.gz in your current working directory,Extract the alertmanager-0.22.2.linux-amd64.tar.gz archive with the following command:
   ```
    $ tar xzf alertmanager-0.22.2.linux-amd64.tar.gz
   ```
   * Now, move the alertmanager-0.22.2.linux-amd64 directory to /opt/ directory and rename it to alertmanager as follows:
   ```
    $ sudo mv -v alertmanager-0.22.2.linux-amd64 /opt/alertmanager
   ```
   * Change the user and group of all the files and directories of the /opt/alertmanager/ directory to root as follows:
   ```
    $ sudo chown -Rfv root:root /opt/alertmanager
   ```
   * In the /opt/alertmanager directory, you should find the alertmanager binary and the Alert Manager configuration file alertmanager.yml, as marked in the screenshot below. You will use them later. So, just keep that in mind.
   * Alert Manager needs a directory where it can store its data. As you will be running Alert Manager as the prometheus system user, the prometheus system user must have access (read, write, and execute permissions) to that data directory.
   You can create the data/ directory in the /opt/alertmanager/ directory as follows:
   ```
    $ sudo mkdir -v /opt/alertmanager/data
   ```
   * Change the owner and group of the /opt/alertmanager/data/ directory to prometheus with the following command:
   ```
    $ sudo chown -Rfv prometheus:prometheus /opt/alertmanager/data
   ```
   * Now, you have to create a systemd service file for Alert Manager so that you can easily manage (start, stop, restart, and add to startup) the alertmanager service with systemd.To create a systemd service file alertmanager.service, run the following command:
   ```
    $ sudo nano /etc/systemd/system/alertmanager.service
   ```
   * Refer **alertmanager.service** pushed over github.
   * For the systemd changes to take effect, run the following command:
   ```
    $ sudo systemctl daemon-reload
   ```
   * Now, start the alertmanager service with the following command:
   ```
    $ sudo systemctl start alertmanager.service
   ```
   * Add the alertmanager service to the system startup so that it automatically starts on boot with the following command:
   ```
    $ sudo systemctl enable alertmanager.service
   ```
   * Check  the alertmanager service is active/running.
   ```
    $ sudo systemctl status alertmanager.service
   ```

## Custom Configurations:
   - **1.Prometheus**
    To monitor the targetted NGINX instance we have to register it's ports that are working as service endpoints into prometheus server. The way we can do that is by adding the IP addresses of service running over instance into **prometheus.yml**file. 
    This file contains 3 sections in our case
      * alertmanager configuration
      * alert-rules configuration
      * prometheus targets
         1. **Alertmanager Configuration:** In this section we configure the alertmanager service running on port 9093.
         2. **Alert-Rules Configuration:** These are useful to monitor the services running over instance with the help of expression provided into alert rules.
         3. **Prometheus Targets:** These are IP addresses of services running over NGINX server in order to monitor them.
    Refer to file **prometheus.yml.**
    Image References:
       * **prometheus_target_with_private_networks.png**
       * **alerts_in_pending_state.png**
       * **alerts_on_firing_state.png**
       * **nginx_mertix_graph.png**
       * **prometheus_targets_down.png**

   - **2.Alert Rules**
    As mentioned, these are expressions that are used monitor the services on basis of provided expressions.The file contains
       * alert: gives information of alert type
       * expr: mathematical expression to monitor services over instance
       * label: give hint of alert
       * annotation: detailed description of alert.
    Refer to file **alert-rules.yml.**
    Image Reference:
       * **alert-expression.png**

   - **3.Alertmanager**
    When alarm gets triggered by prometheus, it gets routed to alertmanager. Alertmanager then, as configured sends notification to email or slack or any other communication channel. Here , we demonstrated how it sends notification to registered email.
    **NOTE: In-order to recieve notifications over email, it is mandatory to allow less secure apps to access gmail.Link to it(https://support.google.com/accounts/answer/6010255?hl=en).**Alertmanager consist of two important sections
       * route:  to send alert notification
       * reciever:  will get responses of alerts
    Refer to file **alertmanager.yml.** 
    Image References:
       * **alertmanager-configuration.png**
       * **alerts_in_alertmanager.png**
       * **email_alert.png**
   
   - **4.Grafana**
    Once you log into grafana:
    * select option for create data source
    * select **prometheus**from list of various data sources
    * at this step , two main thing need to be configured
       * name: as it will be useful after some time so just keep it in mind
       * url: prometheus server's url **(http://localhost:9090)**
       * save & test the URL.
    * Now , in-order to monitor the nginx and node-exporter metics, we need node_exporter dashboard. To add node_exporter dashboard follow steps:
       * select `+` symbol over dashboard.
       * enter dashboard id `1860`(you can select dashboard as per your choise) & check `Load`
       * name the dashboard as per your need
       * select prometheus data source that we have created. (as mentioned above) & check `import`
       * Now, you can see the nginx dashboard as shown in image **grafana_node_exporter_dashboard.png** 
    Image References:
       * **grafana_node_exporter_dashboard.png**
       