## v0.1.3

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

## v0.1.2

* Improve error message when the needed directories do not exist. 

## v0.1.1

* Fix startup error.


## v0.1.0

* First release.

