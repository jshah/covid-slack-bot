# Covid Tracker

Covid Tracker is a slack bot that consumes data from [The Covid Tracking Project](https://covidtracking.com/) API (updated daily) and displays it in Slack.

## Installation

Click [here](https://slack.com/oauth/v2/authorize?client_id=712956700342.1215553228262&scope=commands) to install Covid Tracker in your workspace. 

Covid Tracker is not listed on the Slack app directory because Slack is only accepting COVID related applications from official sources (understandable). Nevertheless, Covid Tracker is open source, so you can see exactly what you're installing and verify the code behind displaying this data. [The Covid Tracking Project](https://covidtracking.com/) is a trusted source for data on COVID-19.

## Features

### Covid State Data

_Fetches COVID data about given state as of today._

**Usage:** `/covid-state-data [state code]`

**Example:** `/covid-state-data CA`

![Covid State Data](public/images/covid-state-data.png)

### Covid USA Data

_Fetches COVID data about the United States as of today._

**Usage:** `/covid-usa-data`

![Covid USA Data](public/images/covid-usa-data.png)

## FAQ

**How can I report a problem?**

Create an issue on the Github repository.

**Can I Contribute?**

Yes! Please fork this repository and submit a pull request. I will review it, test it manually, and merge it in.

## Attributions

[The Covid Tracking Project](https://covidtracking.com/) for providing data.

Covid Tracker's app icon is made by Freepik from https://www.flaticon.com/.
