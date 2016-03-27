


Previous Design:
================

For the configuration, I was going to use a SQLITE db.
This was inspired by Mongrel2, which uses SQLITE for the configuration.
However, This was harder to wrote code, especially for escaping input.
I changed it to use plaintext files on the filesystem. This also
helps it to keep track using git (ie version control).
It is also easier to implement and edit.


