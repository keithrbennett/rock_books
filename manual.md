# RockBooks Manual


| Note: |
| ---- |
| See also the [README.md file](README.md) for an overview of high level concepts. |


### Getting Started

Install the RockBooks software:

`gem install rock_books`

It is recommended that you create a directory structure such as this:

```.
├── 2021-xyz-inc
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

The last five can contain your non-RockBooks specific files that you would normally keep anyway. These directories will be offered by the reports home page web interface merely to navigate the filesystem, with links to view the files using the default application for that file type. Receipts are handled specially though -- you can specify a receipt in a journal and it will be checked for existence in the Receipts report. In the future we hope to generate hyperlinks to both receipts and invoices in the journal reports.

Feel free to organize your files in subdirectories of these directories in whatever way makes sense to you. I have subdirectories of `receipts` for each month (`01`, `02` ... `12`).


### Version Control

Tracking this directory tree with version control software such as `git` is _highly_ recommended because it provides:

* free cloud backup in a private repository with Github, Gitlab, and/or Bitbucket
* an audit trail with human readable diffs
* manageable collaboration


### Chart of Accounts

You will need a chart of accounts in the `rockbooks-inputs` directory. A sample chart of accounts is provided in the sample data (see [sample_data/minimal/rockbooks-inputs/2018-xyz-chart-of-accounts.txt](sample_data/minimal/rockbooks-inputs/2018-xyz-chart-of-accounts.txt)).


### Journals

You will need journals. Usually there would be one journal per external financial institution account, such as checking and credit card accounts. Samples have been provided in the sample_data/minimal/rockbooks-inputs directory of the gem:

* [Checking](sample_data/minimal/rockbooks-inputs/2018-xyz-checking-journal.txt)
* [Credit Card](sample_data/minimal/rockbooks-inputs/2018-xyz-visa-journal.txt)


### General Journal

The general journal is a special journal that is not associated with any particular account. One use of the general journal is for entering the balances of the assets, liabilities, and equity accounts at the beginning of the reporting period (usually a year). A sample general journal is at [sample_data/minimal/rockbooks-inputs/2018-xyz-general-journal.txt](sample_data/minimal/rockbooks-inputs/2018-xyz-general-journal.txt).

The general journal is a special case of journal because transactions in it do not have an implied account (e.g. the checking account for a checking account journal); both sides of the transaction need to be explicitly specified. This is its strength and purpose; it is intended to be used where a transaction would not fit in a regular journal.


### Terminology Usage

* _data file_ - a RockBooks input data file, which is a text file with the extension `.txt`

* _document_ - a RockBooks logical document such as a chart of accounts, a journal, etc., usually containing information parsed from a data file

* _input records_ - repeating records appropriate to the document type, i.e. accounts for the chart of accounts and transactions for journals

* _document properties_ - per document properties such as title, account; property names are preceded by `@` and initialized like this: `@account: ck_abc`.


### Input Data File Format

#### Plain Text

Input data files are plain text files. We recommend using a text editor and _not_ a word processor for them. If you don't already have a favorite text editor, some excellent graphical text editors are [VS Code](https://code.visualstudio.com/), [Atom](https://atom.io/), and [Brackets](http://brackets.io/).

Fields are space separated; any number of spaces can be used.

#### Comment Lines

Lines beginning with `#` will be ignored when the input data is parsed. Therefore, comment lines will not be included in the generated reports. Comment lines are useful for explanations that are too verbose for the reports, but that should be available for deeper research. An example might be several lines of explanatory notes about an unusual transaction.


#### Document Properties

Data lines that contain the value of document properties,
as opposed to input records, will be expressed as lines beginning with `@`:

```
@doc_type: journal
@title: "ABC Bank Checking Account Disbursements Journal"
@account: ck_abc
```

#### Input Records

Input records are records of a type appropriate to the document:

* chart of accounts - each account
* journals - each transaction

Input records are, in general, entered into the text files after all properties. One exception is that the `@date_prefix` is often specified in multiple places in the journal, usually with a new month (e.g. `@date_prefix: 2021-11`).



Data lines will contain fields that an be separated with an arbitrary number of spaces, e.g.:

```
2021-05-18   123.45   supplies 
```

In journals, all entries will begin with dates, and all dates begin with numerals, so the
presence of a numeral in the first column will be interpreted as the beginning of a new
transaction (entry). Any lines following it not beginning with a `#` or number will be
assumed to be the textual description of the transaction, and will be saved along with
its other data and included in reports.

In order to make the entry of dates more convenient, many documents will support
a `@date_prefix` property that will be prepended to dates. For example, if this prefix
contains `2021-`, then subsequent dates must exclude that prefix since it will be
automatically prepended. So, for example, a journal might contain the following lines:

```
@date_prefix: 2021-
# ...more lines...
05-29   37.50   ofc.spls
05-30   22.20   tr.taxi
```

All date strings must use the format `YYYY-MM-DD`, because that's what will be expected
by the application when it converts the date strings into numeric dates.



### Chart of Accounts

Pretty much everything in this application assumes the presence of a chart of accounts
listing the accounts, including their codes, types, and names.

You'll need to provide a chart of accounts file that includes the following line in the header:

`@document_type: chart_of_accounts`

This file should contain the accounts
that will be used. Each account should contain the following fields:

| Property Name | Description |
| ------------- | ------------- |
| code          | a short string with which to identify an account, e.g. `ret.earn` for retained earnings
| type          | 'A' for asset, 'L' for liability, 'O' for (owners) equity, 'I' for income, and 'E' for expenses.
| name          | a longer more descriptive name, used in reports, so no more than 30 or so characters long is recommended
  

So, the chart of accounts data might include something like this:

```
ck.xyz       A   XYZ Bank Checking Account
loan.owner   L   Loan Payable to Owner
o.equity     O   Owner's Equity
sls.cons     I   Consulting Sales
tr.airfare   E   Travel - Air Fare
```

Although hyphens and underscores are typically used to logically separate string fragments,
we recommend periods; they're much easier to type, and you'll be doing a _lot_ of typing.

There is no maximum length for account codes, and reports will automatically align based
on the longest account code. However, keep in mind that you will need to type these codes,
and they will consume space in reports.

For clarity, it is recommended that all accounts for each of the five account types be grouped together. That is, list all the assets first, then all the liabilities, etc.


### Journals

There is no particular restriction on what journals should be used, or which transactions should go in which journal. Do whatever makes the most sense in the context of your entity's financial activities. Each journal is merely an entry point for data into the ultimate list of transactions used to arrive at account balances. You could even (theoretically) have multiple journals for the same bank account, such as one per quarter or month, if that made them more manageable for you.

Here are some examples of possible journals:

* a checking account
* a credit card account
* a Paypal account
* sales (all sales, or 1 journal per client)
* a loan to/from shareholder/owner account

Each journal data file needs to contain:

`@doc_type: journal`

Also, it needs to identify the code of the account the journal is representing.
So for example, if it is a journal of a PayPal account, and the PayPal 
account's code is `paypal`, then you'll need a line like this in your journal file:

`@account_code: paypal`

For your convenience, when entering transactions in a journal (but _not_ a _general_ journal),
you may enter all numbers going in the direction natural for that journal as positive numbers.

For example, a _Cash Disbursements Journal_ (something like a
check register) for an account that has more outgoing than incoming transactions, may contain a transaction like this:

```
05-29   37.50   ofc.spls
```

There may be many transactions in your journal, and it would be cumbersome to have to
type minus signs in front of all of them if they were credits.

Because of this, the program allows you to configure each journal as to the direction
(debit or credit) of the transaction. This is done with the `@debit_or_credit` property.

For an asset journal whose numbers will be crediting the main account
(e.g. a cash disbursements journal whose entries will primarily be crediting
the cash account), you would set the property to `debit`:

```
@debit_or_credit: debit
```


#### General Journal

Since the general journal is a special form of journal that does not have a primary account, 
debits and credits need to be specified literally as account code/amount
pairs, where positive numbers will result in debits, and negative numbers will result in credits, e.g.:

```
03-10   tr.perdiem.mi   495.00   loan.to.sh  -495.00
Per Diem allowance for conference trip
```



    
