# Installing vuh action

A Github action for installing and configuring [vuh](https://github.com/Greewil/version-update-helper).

## Usage

If all you need is latest vuh version, simply add this to your workflow:
```yaml
- name: Install VUH
  uses: Greewil/version-update-helper@gha/install/v1
```

If you want to install specific vuh version:
```yaml
- name: Install VUH
  uses: Greewil/version-update-helper@gha/install/v1
  with:
    version: '2.14.0'
```
Version could be '2.14.0' or 'v2.14.0'.

