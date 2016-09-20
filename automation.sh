#!/bin/bash
#Building the server application

if [ -d ./devops_test ];
then 
	cd devops_test
	git pull
	echo "updating repo"
else
	echo "cloning repo"
	git clone --recursive https://github.com/echtra/devops_test
	cd devops_test
fi

mkdir -p build
cd build
cmake .. > build.log
make >> build.log 
mv -f build.log ../../
cd ../../ # move back to parent directory after build

var=$(docker ps -a | grep 'ubuntu:[(app)/(redis)]' -c)
if [ "$var" = "2" ]; then
	docker stop $(docker ps -a -q) > deploy.log
	docker rm $(docker ps -a -q) >> deploy.log
fi

var=$(docker images| grep 'ubuntu[ \t]*base' -c)
if [ "$var" = "0" ]; then
	echo "-----------BUILDING BASE IMAGE----------------" >> deploy.log
	docker build -f ./DockerFiles/Dockerfile_Base/Dockerfile . -t ubuntu:base >> deploy.log
fi

var=$(docker images| grep 'ubuntu[ \t]*app' -c)
if [ "$var" = "0" ]; then
	echo "-----------BUILDING APP SERVER IMAGE----------------" >> deploy.log
	docker build -f ./DockerFiles/Dockerfile_App/Dockerfile . -t ubuntu:app >> deploy.log
else
	echo "-----------REMOVING EXISTING APP SERVER-------------" >> deploy.log
	docker rmi ubuntu:app 
	echo "-----------BUILDING APP SERVER IMAGE----------------" >> deploy.log
	docker build -f ./DockerFiles/Dockerfile_App/Dockerfile . -t ubuntu:app >> deploy.log
fi

var=$(docker images| grep 'ubuntu[ \t]*redis' -c)
if [ "$var" = "0" ]; then
	echo "-----------BUILDING REDIS SERVER IMAGE----------------" >> deploy.log
	docker build -f ./DockerFiles/Dockerfile_Redis/Dockerfile . -t ubuntu:redis >> deploy.log
fi

echo "-----------STARTING REDIS SERVER----------------" >> deploy.log
docker run --name C_Redis -d ubuntu:redis >> deploy.log

echo "-----------STARTING APP SERVER----------------" >> deploy.log
docker run --link C_Redis:db -p 80:8082 -d ubuntu:app ./server 172.17.0.2 6379  >> deploy.log

testContent=$(wget http://localhost:80 -q -O -)
echo $testContent > test.log
var=$(echo $testContent| grep "Hello World!" -c)
if [ "$var" = "1" ]; then
	echo "TEST SUCCESSFUL"
else 
	echo "TEST FAILED"
fi
