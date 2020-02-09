#!/bin/bash

echo 'deploying'

git add -A
git commit -m 'update'
git push origin source

hugo

cd public

git add -A
git commit -m 'update'
git push origin master

echo 'deployment complete'
