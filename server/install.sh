#!/bin/bash
set -x

apt update
apt install -y nginx docker.io
systemctl start nginx
systemctl enable nginx

mkdir -p image


#subconverter
wget -P image https://image-1253922138.cos.ap-chengdu.myqcloud.com/image/subconverter.tar
docker load -i image/subconverter.tar
docker run -d --name subcon --restart=always -p 25500:25500 tindy2013/subconverter:latest
cp conf/converter.conf /etc/nginx/sites-enabled/
nginx -s reload

#subweb
wget -P image https://image-1253922138.cos.ap-chengdu.myqcloud.com/image/subweb-local.tar
docker load -i image/subweb-local.tar
docker run -d -p 58080:80 --restart always --name subweb subweb-local:latest
cp conf/subweb.conf /etc/nginx/sites-enabled/
nginx -s reload

#sun-panel
echo "install sun-panel"
wget -P image https://image-1253922138.cos.ap-chengdu.myqcloud.com/image/sun-panel.tar
docker load -i image/sun-panel.tar
mkdir -p ~/docker/sun-panel/{conf,uploads,database}
docker run -d --restart=always -p 3002:3002 \
  -v $HOME/docker/sun-panel/conf:/app/conf \
  -v $HOME/docker/sun-panel/uploads:/app/uploads \
  -v $HOME/docker/sun-panel/database:/app/database \
  --name sun-panel hslr/sun-panel
cp conf/dashboard.conf /etc/nginx/sites-enabled/
nginx -s reload

#frp
wget -P image https://image-1253922138.cos.ap-chengdu.myqcloud.com/image/frp_0.43.0_linux_amd64.tar.gz
echo "install frp"
mkdir -p /home/frp
tar -zxvf image/frp_0.43.0_linux_amd64.tar.gz -C /home/

cp -r /home/frp_0.43.0_linux_amd64/* /home/frp/
cp config/frps.ini /home/frp/frps.ini

cp config/frps.service /etc/systemd/system/
systemctl daemon-reload
systemctl restart frps.service
systemctl enable frps.service
cp conf/frps.conf /etc/nginx/sites-enabled/
nginx -s reload




