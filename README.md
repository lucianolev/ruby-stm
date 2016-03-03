STM for the Ruby language
=========================

Requirements
------------
Gems: parser, unparser.

Supports both MRI>2.1 and Rubinius>3.14.

Usage
-----

First, require ruby_core_ext/proc.rb to extend Proc class with the 'atomic' method.

Send the 'atomic' message to a Proc you want to execute atomically.

To execute atomically and handle a commit conflict use 'atomic\_if\_conflict \&a\_block' 

Also, 'atomic\_retry' is available for automatic retry the transaction on commit conflict.

Known issues
------------

- Cannot handle multiple procs in a single line (separated by ';').
- Nested transactions are not supported.
- For the moment, atomicity is only guaranteed for instance variables (including class instance variables).