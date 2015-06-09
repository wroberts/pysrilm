=========
 pysrilm
=========

Python Interface to SRILM
(c) Will Roberts   9 June, 2015

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
