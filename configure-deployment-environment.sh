#!/bin/bash

########## Please change the following variables ##########
# DEPLOYMENT_NAME (e.g. afm) is the short code representing the landing zone.
# ENVIRONMENT (e.g. env1) is the short code for the environment
# LOC_CODE (e.g. eun) is the short code for the location.
# you can find the short codes in the azure resource group name, e.g. rg-aca-env1-afm-eun

# APP_INSIGHTS_CONNECTION_STRING is the connection string of the application insights instance

export DEPLOYMENT_NAME="afm"
export ENVIRONMENT="env1"
export LOC_CODE="eun"
export APP_INSIGHTS_CONNECTION_STRING="InstrumentationKey=17c71bf5-cf69-4261-8d87-4ed79bc2f0f9;IngestionEndpoint=https://northeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://northeurope.livediagnostics.monitor.azure.com/"
