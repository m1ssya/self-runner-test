# self-runner-test

Test push for self-hosted runner.

## Linux self-hosted runner verification

The `Self Hosted Runner Test` workflow targets a repository runner with all of
the following labels:

- `self-hosted`
- `Linux`
- `X64`

For pull requests targeting `main`, the workflow checks out the merge commit
and runs `scripts/verify-self-hosted-runner.sh`. The script fails when the job is
scheduled on an unexpected operating system or architecture. It also verifies
the checked-out commit, prints basic host diagnostics, and writes a concise
summary to the GitHub Actions job summary.

The workflow can also be started manually:

```bash
gh workflow run self-hosted-test.yml --ref main
```

Inspect the latest run with:

```bash
gh run list --workflow self-hosted-test.yml --limit 1
```

Retest PR trigger round 100: 2026年 7月 1日 星期三 11时04分32秒 CST

Retest PR trigger round 201: 2026年 7月 3日 星期五 14时20分14秒 CST

Retest PR trigger round 204: 2026年 7月 3日 星期五 14时39分21秒 CST

Retest PR trigger round 301: 2026年 7月 7日 星期二 20时53分30秒 CST
