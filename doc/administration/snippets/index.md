---
type: reference, howto
stage: Create
group: Editor
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Snippets settings **(CORE ONLY)**

Adjust the snippets' settings of your GitLab instance.

## Snippets content size limit

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/31133) in GitLab 12.6.

You can set a maximum content size limit for snippets. This limit can prevent
abuse of the feature. The default value is **52428800 Bytes** (50 MB).

### How does it work?

The content size limit will be applied when a snippet is created or updated.

In order not to break any existing snippets, the limit doesn't have any
effect on them until a snippet is edited again and the content changes.

### Snippets size limit configuration

This setting is not available through the [Admin Area settings](../../user/admin_area/settings/index.md).
In order to configure this setting, use either the Rails console
or the [Application settings API](../../api/settings.md).

NOTE: **IMPORTANT:**
The value of the limit **must** be in bytes.

#### Through the Rails console

The steps to configure this setting through the Rails console are:

1. Start the Rails console:

   ```shell
   # For Omnibus installations
   sudo gitlab-rails console

   # For installations from source
   sudo -u git -H bundle exec rails console -e production
   ```

1. Update the snippets maximum file size:

   ```ruby
   ApplicationSetting.first.update!(snippet_size_limit: 50.megabytes)
   ```

To retrieve the current value, start the Rails console and run:

  ```ruby
  Gitlab::CurrentSettings.snippet_size_limit
  ```

#### Through the API

The process to set the snippets size limit through the Application Settings API is
exactly the same as you would do to [update any other setting](../../api/settings.md#change-application-settings).

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" https://gitlab.example.com/api/v4/application/settings?snippet_size_limit=52428800
```

You can also use the API to [retrieve the current value](../../api/settings.md#get-current-application-settings).

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" https://gitlab.example.com/api/v4/application/settings
```
