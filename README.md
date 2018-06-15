# RockBooks

A super primitive bookkeeping system using text files as input documents and console output
for reporting.

A supreme goal of this project is to give _you_ control over your data. 
Want to serialize it to YAML, JSON, CSV, or manipulate it in your custom code?
No problem! 

It assumes the traditional double entry bookkeeping system, with debits and credits.
In general, assets and expenses are debit balance accounts, and income, liabilities and equity
are credit balance accounts.

So, to really have this software make sense to you, you should probably understand
the double entry bookkeeping paradigm pretty well. 

# Terminology Usage

* document - a RockBooks logical document such as a chart of accounts, a journal, etc.,
usually containing information parsed from a data file

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

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rock_books.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
