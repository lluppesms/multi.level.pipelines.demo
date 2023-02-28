# Multi-Layer Pipeline Variables Example

This repo will show how you can use multiple variable groups in multiple layers of an Azure DevOps pipeline.

This pipeline will use the variables Environments and Manufacturing Lines to create a matrix of resources.

``` bash
    environments: ['DEV','QA']
    mfgLines: ['Line1','Line2']
```

The variables above will create two plants (environments) each with two lines and all of the resources needed for each of them, like this:

![Pipeline Resources](/docs/Diagram.png)

## Notes

The build/deploy of the IoT Edge modules is still not working and deploying to the Container Registry.... I'm still working on that. For now - it just creates an ACR and has a variable setting which will let you bypass the Edge compilation.

## Reference

[Good Explanation of Pipeline Variables (by Adam the Automator)](https://adamtheautomator.com/azure-devops-variables/)
