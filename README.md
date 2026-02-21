# Validating versions vuh action

A Github action for validating new project version using 
[vuh](https://github.com/Greewil/version-update-helper).

## Usage

You can check that current project version is greater than main branch version 
by calling ```Greewil/version-update-helper@gha/validate-version/v1``` action:
```yaml
- name: Install VUH
  uses: Greewil/version-update-helper@gha/validate-version/v1
```

Or you can validate version for specific module, 
if you are using repository with multiple modules:
```yaml
- name: Validating version using VUH
  uses: Greewil/version-update-helper@gha/validate-version/v1
  with:
    module: "WEB"
```

## Input parameters

- ```version``` - vuh release version (example: v2.13.0 or 2.13.0).
  
  By dafault it will use latest vuh version.
- ```module``` - if you working with mono repository, you can specify application module (example: WEB), otherwise you can leave the module field     blank.
  
  By default its empty.
- ```check-git-diff``` - checking git diff for project/module. 
  If vuh checking git diff it's require to increase version only if current branch has git difference with HEAD..origin/MAIN_BRANCH_NAME.
  
  By dafault its true.

