# Tag Git on Release (Azure DevOps Extension)

Azure DevOps task to tag a git commit in the release pipeline.

## Details

When releasing to an environment, the task will tag the commit id of your source code. 

## How it works

Utilizes the Azure DevOps Rest API to call the annotated tagging method. Creates the tag based on environment variables from the release pipeline.

Authentication is handled by either using an OAuth token, which utilizes the built-in System.Accesstoken variable in Azure DevOps or Person Access Token (PAT). Adding a PAT can be found under the "Advanced" drop down in the task options.

## Note

Enabling "Allow scripts to access the OAuth token" can be found under the "Agent Job/Phase" section of the selected stage.

## Contribute 

Please feel free to make suggestions, improvments, and features you would like to see added to the extension.
