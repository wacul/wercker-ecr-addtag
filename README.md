Wercker step for aws ecr add tag
=======================

# Example

```
deploy:
  steps:
    - wacul/ecr-addtag:
        key: $AWS_ACCESS_KEY_ID
        secret: $AWS_SECRET_ACCESS_KEY
        region: $AWS_DEFAULT_REGION
        aws-registry-id: $AWS_REGISTRY_ID
        repository: repo
        source-tag: latest
        add-tag: tagname
```


