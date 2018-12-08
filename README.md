# A transparent implementation of Software Transactional Memory for the Ruby language

This is an academic project. It's not optimized in any way to be used in real life, 
resource demanding escenarios (it should be useful as a base to achieve that goal though).

Paper (Spanish): http://dc.sigedep.exactas.uba.ar/media/academic/grade/thesis/leveroni.pdf

## Requirements

Gems: parser, unparser, rspec.

Use `bundle install` to install them.

Tested with:
 - MRI 2.3+ (may work on 2.1+ but untested)
 - Rubinius 3.69 (may work with newer versions but untested)

## Usage

First, require 'src/stm' to extend Proc class with the 'atomic' method and it's variants.

Send the 'atomic' message to a Proc you want to execute atomically.

To execute atomically and handle a commit conflict use 'atomic\_if\_conflict \&a\_block'.

Also, 'atomic\_retry' is available for automatic retry the transaction on commit conflict.

## "Real life" example

See the `examples` directory for scripts that demonstrate how to use this library.

Use 'transfer.call' instead of 'transfer.atomic_retry' to execute non-atomically.

## Known issues

- Cannot handle multiple procs defined in a single line (separated 
by ';').
- Methods or procs defined by metaprogramming means (like eval) 
cannot be executed inside a transaction out of the box (must 
implement atomic variant manually).
- Nested transactions are not supported (should be relatively easy to add support for it).
- For the moment, atomicity is only guaranteed for instance 
variables (including class instance variables but not class 
variables).
- Performance is poor, especially in Rubinius.
