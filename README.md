# RockBooks

| Note: |
| ---- |
| The [manual.md file](manual.md) has more detailed information about RockBooks usage. |

**A simple but useful accounting software application for very small entities.**

A supreme goal of this project is to give _you_ control over your data. Want to serialize it to YAML, JSON, CSV, or manipulate it in your custom code? No problem! 

After entering the data in input files, there is a processing step (a single command) that is done to validate the input and generate the reports and home page. (This could be automated using `guard`, etc.) An `index.html` is generated that links to the reports, input documents, receipts, invoices, statements, worksheets, etc., in a unified interface. This `index.html` can be opened locally using a `file:///` URL but the directory tree can easily be copied to a web server for shared and/or remote access.

#### How RockBooks Is Different

Mainstream accounting packages like QuickBooks have lots of bells and whistles, but are opinionated and not customizable; if you want to use your data _your_ way, or do something differently, you're out of luck.

RockBooks is different in many ways.

The software is in the form of Ruby classes and objects that can be incorporated into your own code for your own customizations. The data is available to programmers as Ruby objects (and therefore JSON, YAML, etc.) In addition, RockBooks could be used as an engine with alternate pluggable UI's. Feel free to write a web app for inputting the data!

Rather than hiding accounting concepts from the user, RockBooks embraces and exposes them. There is no attempt to hide the traditional double entry bookkeeping system, with debits and credits. Accounting terminology is used throughout (e.g. "chart of accounts", "journals"). Some understanding of accounting or bookkeeping principles is helpful but not absolutely necessary.

To simplify its implementation, RockBooks assumes some conventions:

* Input documents (chart of accounts, journals) are assumed to be in the `rockbooks-inputs` directory.

* The following directories are assumed to contain the appropriate content, or nothing at all. They are simply presented on the reports web page as directories in the filesystem, so you can feel free to organize files in subdirectories as you see fit:

  * `receipts` - receipts documenting expenses & other transactions
  * `invoices` - sales/services invoices
  * `statements` - statements from banks, etc.
  * `worksheets` - spreadsheets, etc., e.g. mileage and per diem calculations
  
#### Supported Operating Systems

At this time, RockBooks is tested only on Mac OS and Linux. However, it will probably work fine on Windows.

#### Text Files as Input

Instead of a web interface, data input is done in plain text files. This isn't as fancy but has the following advantages:

* Data can be tracked in git or other version control software, offering a readable and easily accessible audit trail, manageable collaboration, with free cloud backup including history with Github, Gitlab, Bitbucket, etc.

* Text notes of arbitrary length can be included in input files, and included or excluded in reports. This can be useful, for example, in explaining the context of a transaction more thoroughly than could be done in a conventional accounting application. This can be helpful to accountants, auditors, etc., saving the time, and you money, and can demonstrate your helpfulness and transparency.

* Data will be longer lived, as it is readable and printable without any special software.

* Users can use their favorite text editors.

* All data entry can be done without moving the hands away from the keyboard (assuming the editor software supports it, as does `vim`).


#### The Accounting Period

There is no handling of end of year closings or the like; the entire set of data in the input files is considered included in the reporting period when generating the reports. Therefore, the best approach is to create a new data set for each year. The chart of accounts and journal files can be copied from the previous year and modified as necessary.

#### RockBooks Help Text

```
Command Line Switches:                    [rock-books version 0.10.0 at https://github.com/keithrbennett/rock_books]

-i   input directory specification, default: './rockbooks-inputs'
-o   output (reports) directory specification, default: './rockbooks-reports'
-r   receipts directory, default: './receipts'
-s   run in shell mode

Commands:

rec[eipts]                - receipts: a/:a all, m/:m missing, e/:e existing, u/:u unused
rep[orts]                 - return an OpenStruct containing all reports (interactive shell mode only)
w[rite_reports]           - write all reports to the output directory (see -o option)
c[hart_of_accounts]       - chart of accounts
h[elp]                    - prints this help
jo[urnals]                - list of the journals' short names
proj[ect_page]            - prints the RockBooks Github project page URL
rel[oad_data]             - reload data from input files
q[uit]                    - exits this program (interactive shell mode only) (see also 'x')
x[it]                     - exits this program (interactive shell mode only) (see also 'q')

When in interactive shell mode:
* use quotes for string parameters such as method names.
* for pry commands, use prefix `%`.
* you can use the global variable $filter to filter reports
```

----

## What RockBooks Is Not

As a product written by a single developer in his spare time, 
RockBooks lacks many conveniences of traditional accounting software programs, such as:

* Import of data from financial institutions
* On the fly data validation
* Data entry conveniences such as drop down selection lists for data such as accounts
* Fancy reporting and graphing -- however, RockBooks' bringing links to all the entity's documentation and output into a single web page may well be more useful


## Installation

    $ gem install rock_books

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/keithrbennett/rock_books](https://github.com/keithrbennett/rock_books).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
