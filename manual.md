# RockBooks Manual

### Getting Started

Install the RockBooks software:

`gem install rock_books`

It is recommended that you create a directory structure such as this:

```.
├── 2018-xyz-inc
│   ├── invoices
│   ├── receipts
│   ├── references
│   ├── rockbooks-inputs
│   ├── rockbooks-reports
│   ├── statements
│   └── worksheets
```

The top level is a directory containing your data for a given entity for a single reporting period (probably a year).

Here are the subdirectories:

* `rockbooks-inputs` - all input documents (chart of accounts, journals)
* `rockbooks-reports` - all generated reports and web content
* `receipts`
* `invoices`
* `references`
* `statements`
* `worksheets`

The last five contain your non-RockBooks specific files that you would normally keep anyway. These directories will be offered by the reports home page web interface merely to navigate them and view the files as they are, using the default application for that file type. Receipts are handled specially though -- you can specify a receipt in a journal and it will be checked for existence in the Receipts report. In the future we hope to generate hyperlinks to both receipts and invoices in the journal reports.

Feel free to organize your files in subdirectories of these directories in whatever way makes sense to you. I have subdirectories of `receipts` for the respective months (`01`, `02` ... `12`).


### Version Control

Tracking this directory tree with version control software such as `git` in a private repository is _highly_ recommended because it provides:

* free cloud backup with Github, Gitlab, and/or Bitbucket
* an audit trail with human readable diffs
* manageable collaboration


### Chart of Accounts

You will need a chart of accounts in the `rockbooks-inputs` directory. A sample chart of accounts is provided in the sample data (see [sample_data/minimal/rockbooks-inputs/2018-xyz-chart-of-accounts.txt](sample_data/minimal/rockbooks-inputs/2018-xyz-chart-of-accounts.txt)).


### Journals

You will need journals. Usually there would be one journal per external financial institution accounts, such as checking and credit card accounts. Samples have been provided in the sample_data/minimal/rockbooks-inputs directory of the gem:

* [Checking](sample_data/minimal/rockbooks-inputs/2018-xyz-checking-journal.txt)
* [Credit Card](sample_data/minimal/rockbooks-inputs/2018-xyz-visa-journal.txt)


### General Journal

The general journal is a special journal that is not associated with any particular account. One use of the general journal is for entering the balances of the assets, liabilities, and equity accounts at the beginning of the reporting period (usually a year). A sample general journal is at [sample_data/minimal/rockbooks-inputs/2018-xyz-general-journal.txt](sample_data/minimal/rockbooks-inputs/2018-xyz-general-journal.txt).

The general journal is a special case of journal because transactions in it do not have an implied account (e.g. the checking account for a checking account journal); both sides of the transaction need to be explicitly specified. This is its strength and purpose; it is intended to be used where a transaction would not fit in a regular journal.




    
