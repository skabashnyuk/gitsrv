#!/usr/bin/env bash

helm install --create-namespace --namespace bitbucket  bitbucket --values values.yaml .