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

* rockbooks-inputs - all input documents (chart of accounts, journals)
* rockbooks-reports - all generated reports and web content
* receipts
* invoices
* references
* statements
* worksheets

The last five will merely be available to navigate the file system with your browser in the reports home page. Receipts are handled specially though -- you can specify a receipt in a journal and it will be checked for existence in the Receipts report.

Feel free to organize your files in subdirectories of these directories in whatever way makes sense to you. I have subdirectories of `receipts` for the respective months (`01`, `02` ... `12`).

### Version Control

Tracking this directory tree with version control software such as `git` in a private repository is _highly_ recommended to provide:

* free cloud backup with Github, Gitlab, Bitbucket, etc.
* an audit trail with human readable diffs
* manageable collaboration
