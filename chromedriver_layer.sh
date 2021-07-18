#!/bin/bash

mkdir chromedriver_layer
cd chromedriver_layer/
wget https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip -OutFile chromedriver.zip
wget https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-54/stable-headless-chromium-amazonlinux-2017-03.zip -OutFile headless-chromium.zip
Expand-Archive headless-chromium.zip
rm *.zip
