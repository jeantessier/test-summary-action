# test-summary-action

A GitHub Action to summarize JUnit tests in Gradle builds.

It collects JUnit results from each subproject and reports on tests passed and
failed for each subproject.  The report is a simple table written to the
`GITHUB_STEP_SUMMARY`.

## To Use

Here is an example workflow as an example of using this GitHub Action in a job's
steps.

```yaml
jobs:
  build:
    steps:
    - name: Checkout the repo
      uses: actions/checkout@v4

    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Setup Gradle
      uses: gradle/actions/setup-gradle@v3
    - name: Build with Gradle Wrapper
      run: ./gradlew build

    - name: Summarize tests results
      uses: jeantessier/test-summary-action@v1.0.5
      if: ${{ always() }}
```

It uses `if: ${{ always() }}` so it can report on failed tests, which would make
the previous step fail.

It will produce a summary table like the following.

| Subproject        |       Status       | Tests | Passed | Skipped | Failures | Errors |
|-------------------|:------------------:|:-----:|:------:|:-------:|:--------:|:------:|
| integration-tests | :white_check_mark: |  714  |  714   |    0    |    0     |   0    |
| lib               |        :x:         | 2250  |  2248  |    0    |    2     |   0    |
| webapp            | :white_check_mark: |  72   |   0    |   72    |    0     |   0    |
