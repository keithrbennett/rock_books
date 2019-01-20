# RockBooks

A simple but useful accounting software application for small entities.

A supreme goal of this project is to give _you_ control over your data. Want to serialize it to YAML, JSON, CSV, or manipulate it in your custom code? No problem! 

After entering the data in input files, there is a processing step (a single command) that is done to output the reports and home page. (This could be automated using `guard`, etc.) This generates an `index.html` that links to the reports, input documents, receipts, invoices, statements, worksheets, etc., in a unified interface. This `index.html` can be opened _locally_ using a `file:///` URL but the directory tree can easily be copied to a web server for shared and remote access.

#### How RockBooks Is Different

Mainstream accounting packages like QuickBooks have lots of bells and whistles, but are opinionated and not customizable; if you want to use your data _your_ way, or do something differently, you're out of luck.

RockBooks is different in many ways.

The software is in the form of Ruby classes and objects that can be incorporated into your own code for your own customizations. The data is available to programmers as Ruby objects (and therefore JSON, YAML, etc.)

Rather than hiding accounting concepts from the user, RockBooks embraces and exposes them. There is no attempt to hide the traditional double entry bookkeeping system, with debits and credits, and accounting terminology is used throughout (e.g. "chart of accounts", "journals"). Some understanding of accounting or bookkeeping principles is helpful but not absolutely necessary.

To simplify its implementation, RockBooks assumes some conventions:

* The following directories are assumed to contain the appropriate content:
** `receipts` - receipts documenting expenses & other transactions
** `invoices` - sales/services invoices
** `statements` - statements from banks, etc.
** `worksheets` - spreadsheets, etc., e.g. mileage and per diem calculations
** `rockbooks-inputs` - journals, chart of accounts, etc.



##### Text Files as Input

Instead of a web interface, data input is done in plain text files. This isn't as fancy but has the following advantages:

* Data can be tracked in git or other version control software, offering a readable and easily accessible audit trail.

* Text notes of arbitrary length can be included in input files, and included or excluded in reports. This can be useful, for example, in explaining the context of a transaction more thoroughly than could be done in a conventional accounting application.

* Data can be easily printed out.

* Data will be longer lived, as it is readable without any special software.

* Users can use their favorite text editors.

* All data entry can be done without moving the hands away from the keyboard.

----


# Terminology Usage

* document - a RockBooks logical document such as a chart of accounts, a journal, etc., usually containing information parsed from a data file

* data file - a RockBooks data file, which is a text file with the extension `.txt`


## Data File Format

Lines beginning with `#` will be ignored.

Data lines that contain the value of document properties,
as opposed to transactions, etc., will be expressed as lines beginning with `@`:

```
@doc_type: journal
@title: "ABC Bank Checking Account Disbursements Journal"
@account: ck_abc
```

Repeating data types such as entries in journals, and accounts in the chart of accounts,
should in general be input after the properties.

Data lines will contain fields that an be separated with an arbitrary number of spaces, e.g.:

```
2018-05-18  123.45 703
```

In journals, all entries will begin with dates, and all dates begin with numerals, so the
presence of a numeral in the first column will be interpreted as the beginning of a new
transaction (entry). Any lines following it not beginning with a `#` or number will be
assumed to be the textual description of the transaction, and will be saved along with
its other data.

In order to make the entry of dates more convenient, many documents will support
a `@date_prefix` property that will be prepended to dates. For example, if this prefix
contains `2018-`, then subsequent dates must exclude that prefix since it will be
automatically prepended. So, for example, a journal might contain the following lines:

```
@date_prefix: 2018-
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
we recommend periods; they're much easier to type, and you'll be doing a lot of that.

There is no maximum length for account codes, and reports will automatically align based
on the longest account code. However, keep in mind that you will need to type these codes,
and they will consume space in reports.

### Journals

Journals (also referred to as _documents_ by this application)
are used to record transactions of, for example:

* cash disbursements (expenditures for a single checking account)
* cash receipts (funds coming into a single checking account)
* combined cash disbursements and receipts
* a credit card account
* a Paypal account
* sales

Each journal data file needs to contain:

`@doc_type: journal`

Also, it needs to identify the code of the account the journal is representing.
So for example, if it is a journal of a PayPal account, and the PayPal 
account's code is `paypal`, then you'll need a line like this in your journal file:

`@account_code: paypal`

For your convenience, when entering transactions in a journal (but _not_ a _general_ journal),
you may enter all numbers going in the direction natural for that journal as positive numbers.

For example, a _Cash Disbursements Journal_ (something like a
check register) may contain a transaction like this:

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

The general journal is a special form of journal that does not have a primary account.

In this journal, debits and credits need to be specified literally as account code/amount
pairs, where positive numbers will result in debits, and negative numbers will result in credits, e.g.:

```
03-10   tr.perdiem.mi   495.00   loan.to.sh  -495.00
Per Diem allowance for conference trip
```



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rock_books'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rock_books

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/keithrbennett/rock_books](https://github.com/keithrbennett/rock_books).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
