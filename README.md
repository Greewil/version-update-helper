# VUH action for collecting project info

A Github action for collecting project info using [vuh](https://github.com/Greewil/version-update-helper).

## Usage

If all you need is kust collect project versions info, simply add this to your workflow:
```yaml
- name: Collecting project versions info
  uses: Greewil/version-update-helper@gha/collect-info/v1
```

### Input parameters

If you want to use specific vuh version:
```yaml
- name: Collecting project versions info
  uses: Greewil/version-update-helper@gha/collect-info/v1
  with:
    version: '2.14.1'
```
Version could be '2.14.1' or 'v2.14.1'.

If you want to collect info for mono repository module:
```
- name: Collecting project versions info
  uses: Greewil/version-update-helper@gha/collect-info/v1
  with:
    module: 'WEB'
```

### Outputs

If you working with single version applocation, 
you can get ```local-version```, ```main-version```, ```suggested-version``` outputs from this action.

If this actionhas some ```module``` input, you can also get ```module-root-path``` from output.

All outputs:
```
outputs:
   local-version:
     description: "Module local (current) version"
     value: ${{ steps.vuh_collect_info.outputs.local-version }}
   main-version:
     description: "Module main version"
     value: ${{ steps.vuh_collect_info.outputs.main-version }}
   suggested-version:
     description: "Module suggested new version"
     value: ${{ steps.vuh_collect_info.outputs.suggested-version }}
   module-root-path:
     description: "Module root path from .vuh config"
     value: ${{ steps.vuh_collect_info.outputs.module-root-path }}
```

