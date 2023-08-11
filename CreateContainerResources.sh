https://learn.microsoft.com/en-us/azure/container-apps/tutorial-code-to-cloud?source=recommendations&tabs=bash%2Ccsharp&pivots=acr-remote

RESOURCE_GROUP="album-containerapps"
LOCATION="centralus"
ENVIRONMENT="env-album-containerapps"
API_NAME="album-api"
FRONTEND_NAME="album-ui"
GITHUB_USERNAME="guccilittlepiggie"
ACR_NAME="acaalbums"$GITHUB_USERNAME

git clone https://github.com/GucciLittlePiggie/containerapps-albumapi-csharp.git

az group create \
  --name $RESOURCE_GROUP \
  --location "$LOCATION"

  az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

  az acr build --registry $ACR_NAME --image $API_NAME .

  az containerapp env create \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION"

  az containerapp create \
  --name $API_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/$API_NAME \
  --target-port 3500 \
  --ingress 'external' \
  --registry-server $ACR_NAME.azurecr.io \
  --query properties.configuration.ingress.fqdn


git clone https://github.com/$GITHUB_USERNAME/containerapps-albumui.git code-to-cloud-ui

az acr build --registry $ACR_NAME --image albumapp-ui .

API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $API_NAME --query properties.configuration.ingress.fqdn -o tsv)

az containerapp create \
  --name $FRONTEND_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/albumapp-ui  \
  --target-port 3000 \
  --env-vars API_BASE_URL=https://$API_BASE_URL \
  --ingress 'external' \
  --registry-server $ACR_NAME.azurecr.io \
  --query properties.configuration.ingress.fqdn

  az group delete --name $RESOURCE_GROUP