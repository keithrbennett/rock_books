# Release Notes

[[go to README](README.md)]

### v0.12.0

* Fix balance sheet grand total computation.
* Update bundler version constraint to ">= 2.2.33" as per dependabot.


### v0.11.0

* Add and fix documentation, especially addition of REPORTS.md about viewing the generated reports.
* Add "Original Input Documents" and "Browse All Data Files" buttons to generated index.html.


### v0.10.0

* Add invoice hyperlinks to generated HTML.
* Improve documentation.
* Add progress bar to report generation.
* Change 'proj[ect]' command to print the project home page URL, rather than call `open` on it. This makes the command useful in more cases and removes environment dependency.
* Remove interactive 'display reports' option. It's not that useful and easy enough to write all reports to disk and selectively view them.
* Fix rep[orts] interactive option.
* Fix and refactor handling of receipt data on command line.
* Add styling to report HTML pages, mostly for centering the reports, increasing the font size, and providing a faint blue background.


### v0.9.0

* Center generated index.html's content.
* Improve report headings.
* Fix index.html hyperlinks to resource (receipts, invoices, statements, worksheets) directories.
* Fix cases where split journal entries were not included in the journal report.


### v0.8.0

* Add metadata to PDF and HTML reports
* Add report generation timestamp and accounting period to all reports.
* Refactoring and cleanup.


### v0.7.1

* Refactor report helpers. 
* Improve/reduce text output during reporting.
* Add title to HTML reports.
* Minor fixes.


### v0.7.0

* Dependencies on external commands in Linux and Mac OS for generating PDF and HTML files has been eliminated,
using the prawn gem for PDF and simple ERB templating for HTML.
* Massive refactoring of reports to separate data generation from presentation.
* Reports are now computed and then written one at a time. Previously they were all computed, then all written.
* ERB is now used for generating text reports.
* Fix receipt hyperlinks in HTML output.
* Improve some error output.
* Various minor improvements and bug fixes.


### v0.6.1

* Linux PDF generation fixed by using wkhtmltopdf instead of cupsfilter.

### v0.6.0

* Linux support added!

### v0.5.0

* Add receipt hyperlinks to HTML output.


### v0.4.0

* Sort unused receipts alphanumerically.
* Add 'x' receipts option for reporting both missing and unused receipts.
* Fix: journals were showing journal account instead of the other account in each transaction.
* Improve Receipts report.


### v0.3.0

* Added ability to report unused receipts.
* Errors now include more context information.
* Improved chart of accounts validation.
* Change license from MIT to Apache 2.


### v0.2.1

* Add help text to readme.


### v0.2.0

* Add instruction manual, modify readme.
* Overhaul generated index.html.
* Add accounting period start and end date to configuration and reports.
* Add validation of transaction dates to ensure within configured date range.
* Make report hash / OpenStruct keys consistently symbols.

### v0.1.6

* Fixed PDF output; PDF files were corrupt because cupsfilter starting sending
output to stderr at some point.


### v0.1.4, v0.1.5

* Intermediate unsatisfactory fixes, these versions were published but yanked. 


### v0.1.3

* Report output now goes to separate txt, html, and pdf subdirectories.
* Add vendor.yml to exclude generated report files from language reporting.
* Use .gitattributes instead of vendor.yml to specify vendored code.
* Add == methods to ChartOfAccounts and Journal classes.
* Rename input files from .rbt to .txt.
* Convert sample input files to DOS line endings.
* Add validation that transaction is balanced.
* Fix so that requesting help shows correct help text, and that passing no args on cmd line triggers help.
* Implement more helpful error messages, with document short name, line number, and line text.
* Add JournalEntryContext and TransactionNotBalancedError classes.
* Add 'from_string' methods to Journal and ChartOfAccounts.


### v0.1.2

* Improve error message when the needed directories do not exist. 


### v0.1.1

* Fix startup error.


### v0.1.0

* First release.

