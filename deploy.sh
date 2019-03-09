#! /bin/bash
# 当前使用hugo 0.53(支持scss)
dir=/home/x1/blog
dir=$PWD
host=proxy
# host=178.157.50.181
port=22

# git pull
# git add .
# git commit -m "自动提交 @arloor $(date)"
# git push

# yum install httpd
# systemctl enable httpd
cd $dir
echo "生成静态资源..."
hugo

echo "上传新的静态资源...."
cd public/
tar  -zcf  public.tar.gz --exclude=public.tar.gz *
if [ "$?" != "0" ]; then
    echo -e "\n 压缩失败，退出"
    rm -rf ../public #删除生成的静态资源
    exit 1
fi

scp -r -P $port ./public.tar.gz  root@$host:~
if [ "$?" != "0" ]; then
    echo -e "\n 上传静态资源失败，退出"
    rm -rf ../public #删除生成的静态资源
    exit 1
fi

ssh root@$host  -p$port "
echo "删除服务器的旧版本静态资源...."
rm -rf /var/www/html/*
tar -zxf public.tar.gz -C /var/www/html/
rm -f public.tar.gz
echo "reload httpd...."
systemctl  reload httpd
"
echo  "部署完毕，请访问 http://"$host
cd $dir
rm -rf public #删除生成的静态资源