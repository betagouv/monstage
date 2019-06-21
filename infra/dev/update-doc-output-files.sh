#!/bin/bash

set -x

git update-index --no-assume-unchanged  doc/internship_offers/create/*
git update-index --no-assume-unchanged  doc/internship_offers/update/*
git update-index --no-assume-unchanged  doc/internship_offers/destroy/*

git add doc/internship_offers

git update-index --assume-unchanged  doc/internship_offers/create/*
git update-index --assume-unchanged  doc/internship_offers/update/*
git update-index --assume-unchanged  doc/internship_offers/destroy/*

