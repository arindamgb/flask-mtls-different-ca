#!/bin/bash
docker rm -f flask-mtls-different-ca
docker build -t flask-mtls-different-ca .
docker run -itd --restart=always --name flask-mtls-different-ca --env-file .env -p 5002:5000 flask-mtls-different-ca
