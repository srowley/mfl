## Changelog

## v0.1.0 - 9 Feb 2019
   * Initial release with support for:
      * players
      * league
      * freeAgents
      * rosters
      * salaryAdjustments

## v0.2.0 - 12 Feb 2019
   * Added support for all exports that are not league-specific, except:
     * siteNews (an rss feed for MyFantasyLeague news)
     * rss (an rss feed of various league data)

The remaining requests are low-priority given that the 
best way to consume them is to simply call the request
directly and consume the output in an RSS reader.

## v0.3.0 - 18 Feb 2019 
   * Added support for league-specific exports, except:
     * pendingWaivers (no sample doc available for testing)
     * pendingTrades (no sample doc available for testing)
     * survivorPool (no sample doc available for testing)
     * ics (just returns an .ics file league calendar)

## v0.3.x TBD
   * Catch at least some errors in league/year before request is made
   * Refactor/reorganize tests for readability

## v0.4.0 TBD
   * Add support for import requests 
