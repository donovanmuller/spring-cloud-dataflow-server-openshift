#!/usr/bin/env bash

# This script downloads the Data Flow Server for OpenShift templates and uploads them into
# a specified project. The default project is `scdf` as per the Getting Started guide from the reference
# documentation. However, the project can be specified as the first argument to this script.
#
# Usage:
#
# $ ./install-templates.sh [project name]
#
# or alternatively:
#
# $ curl -sL https://github.com/donovanmuller/spring-cloud-dataflow-server-openshift/releases/download/1.1.0.RELEASE/scdf-openshift-templates.zip \
#   | bash -s [project name]
#

project=${1:-scdf}

echo "Installing OpenShift templates into project '${project}'..."

curl -o /tmp/scdf-openshift-templates.zip -sL https://github.com/donovanmuller/spring-cloud-dataflow-server-openshift/releases/download/v1.1.0.RELEASE/scdf-openshift-templates.zip
unzip -o /tmp/scdf-openshift-templates.zip -d /tmp/scdf-openshift-templates

shopt -s nullglob
for template in /tmp/scdf-openshift-templates/*.yaml
do
    echo "Installing template '$template'"
    oc replace --force=true -f $template
done

echo "Adding 'edit' role to 'scdf' Service Account..."

oc policy add-role-to-user edit system:serviceaccount:${project}:scdf

echo "Adding 'scdf' Service Account to the 'anyuid' SCC..."

oc adm policy add-scc-to-user anyuid system:serviceaccount:scdf:scdf

echo "Templates installed."
