=========
 pysrilm
=========

Python Interface to SRILM

Copyright (c) Will Roberts   9 June, 2015

License: The source code included in this package is licensed under
the MIT License (see ``LICENSE.txt``).  To install, you will also need
a copy of the `SRILM toolkit`_, for which you will need a license from
SRI.

.. _`SRILM toolkit`: http://www.speech.sri.com/projects/srilm/

Getting Started
===============

You can load a n-gram model like this (note that because SRILM
understands zlib, you can pass gzipped files to the ``read`` method)::

    import srilm
    ngrams = srilm.Ngrams(3)
    ngrams.read('ngram-counts-eu.tsv.gz')

Look up the frequency of some n-gram in the model::

    ngram = ['red', 'flower']
    freq = ngrams.find_count(ngram)

Iterate over all the n-grams of a certain order in a particular
model::

    for (bigram, count) in ngrams.ngrams(2):
        print ' '.join(bigram) + ':', count

Install
=======

Put the SRILM source in the ``srilm`` directory in this directory and
do ``python setup.py install`` or ``python setup.py build_ext``.

Development
===========

For faster turnarounds when hacking on the source code, you can do
``CC="ccache gcc" CXX="ccache c++ python setup.py build_ext"``, as
noted in `this StackOverflow answer <http://stackoverflow.com/a/13176803/1062499>`_.
