# BudURL

### About

This gem provides a simple interface to the BudURL.Pro API, documented [here](http://budurl.com/page/budurlpro-api). BudURL provides URL shortening services as well as analytics, some of which is available externally. In particular, the API allows:

* **Shortening URLs** along with adding notes, setting redirect types, and checking for duplicates,
* **Expanding URLs** which have been shortened using the service,
* **Gathering analytics** such as click counts either since link creation or on a day-by-day basis, filterable by time period.

### Usage

The BudURL API requires an API key for any usage other than URL expansion. More details at their website, [BudURL.Pro](http://budurl.pro).

Initialise a client using `Budurl.new(<API_KEY>)`. It provides `shorten(url, opts)` and `expand(short_url)` functionality; the resulting `Budurl::Url` objects can be used to acquire additional information such as click counts. Options not exposed in code can be passed in as options; generally speaking, any option available through the API should be accessible.
