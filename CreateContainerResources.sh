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

  az group delete --name $RESOURCE_GROUP