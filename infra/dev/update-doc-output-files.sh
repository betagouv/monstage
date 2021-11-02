#!/bin/bash

set -x

git update-index --assume-unchanged  doc/output/internship_offers/create/*
git update-index --assume-unchanged  doc/output/internship_offers/update/*
git update-index --assume-unchanged  doc/output/internship_offers/destroy/*

