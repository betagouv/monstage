#!/bin/bash

set -x

git update-index --no-assume-unchanged  doc/output/internship_offers/create/*
git update-index --no-assume-unchanged  doc/output/internship_offers/update/*
git update-index --no-assume-unchanged  doc/output/internship_offers/destroy/*

git add doc/output/internship_offers

git update-index --assume-unchanged  doc/output/internship_offers/create/*
git update-index --assume-unchanged  doc/output/internship_offers/update/*
git update-index --assume-unchanged  doc/output/internship_offers/destroy/*

