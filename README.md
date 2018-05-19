# RockBooks

A super primitive bookkeeping system using text files as data and console output
for reporting.

It assumes the traditional double entry bookkeeping system, with debits and credits.
In general, assets and expenses are debit balance accounts, and liabilities and equity
are credit balance accounts.

So, to really have this software make sense to you, you should probably understand
the double entry bookkeeping paradigm pretty well. 

# Terminology Usage

* document - a RockBooks logical document such as a chart of accounts, a journal, etc.,
usually containing information parsed from a data file

* data file - a RockBooks data file, which is a text file, with the extension `.rdt`


## Data File Format

Lines beginning with `#` will be ignored.

Data lines that contain the value of document properties,
as opposed to transactions, etc., will be expressed as lines beginning with `@`:

```
@doc_type: journal
@title: "ABC Bank Checking Account Disbursements Journal"
@account: 101
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
assumed to be the textual description of the transaction.

In order to make the entry of dates more convenient, many documents will support
a `@date_prefix` property that will be prepended to dates. For example, if this prefix
contains `2018-`, then subsequent dates must exclude that prefix since it will be
automatically prepended. So, for example, the date 2018-05-18 would need to be entered
as `05-18`.


### Chart of Accounts

Pretty much everything in this application assumes the presence of a chart of accounts
listing the accounts; their id's and their names.


You'll need a chart of accounts file named `chart_of_accounts.rdt`, containing the accounts
that will be used. They should contain:

  attr_reader :date_prefix, :doc_type, :title, :accounts

A commonly used convention for account id's is to assign 3 digit codes to each account,
where the first digit represents the type of account it is:

| First Digit | Account Type  |
| ----------- | ------------- |
|1            |Asset          |
|2            |Liability      |
|3            |Owners' Equity |
|4            |Income         |
|7            |Expenses       |
|9            |Income Taxes   |

So, the chart of accounts data might include something like this:

```
101 XYZ Bank Checking Account
201 Loan Payable to Owner
301 Owner's Equity
401 Consulting Sales
701 Supplies
```


### Journals

Journals are used to record transactions of, for example:

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
account's code is `103`, then `@account_code` must be set to `103`:

`@account_code: 103`

In addition, the debit or credit nature of the journal needs to be specified.
As an example, in the case of a checking account, each entry would credit the
cash account and debit whatever account(s) the money was spent on,
e.g. `712 Rent`. In this case, the `@debit_or_credit` property should be set to
`credit`. This is arbitrary, but the way I remember it is whichever direction
(debit or credit) the money will go in an entry to/from the journal's primary
account.

So if the primary account is a checking account, then each positive entry in the 
journal will result in a credit to the checking account.

Here's what it looks like:

`@debit_or_credit: credit`

#### General Journal

The general journal is a special form of journal that does not have a primary account.

In this journal, debits and credits need to be specified literally as account code/amount
pairs, where positive numbers will result in debits, and negative numbers will result in credits.



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
