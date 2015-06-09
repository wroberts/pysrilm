#!/usr/bin/env cython --cplus
# -*- coding: utf-8 -*-

'''
srilm.pyx
(c) Will Roberts   9 June, 2015

Cython wrapper for the SRILM n-gram statistics container (NgramStats).
'''

cimport cython
from array import array
from cpython cimport array as c_array
from cpython.string cimport PyString_AsString
from cython.operator import dereference
from libc.stdlib cimport malloc, free
from libcpp.string cimport string

cdef extern from "Vocab.h":
    ctypedef int Boolean
    ctypedef unsigned int	VocabIndex
    ctypedef const char	*VocabString
    const VocabIndex	Vocab_None
    cdef cppclass Vocab:
        Vocab()
        VocabString getWord(VocabIndex index)
        VocabIndex getIndex(VocabString name,
                            VocabIndex unkIndex)
        VocabIndex getIndex(VocabString name)
        unsigned int numWords() const
        VocabIndex highIndex() const
        Boolean &toLower()
        Boolean &unkIsWord()
        unsigned int getWords(const VocabIndex *wids,
                              VocabString *words, unsigned int max)
        unsigned int getIndices(const VocabString *words,
                                VocabIndex *wids, unsigned int max,
                                VocabIndex unkIndex)
        unsigned int getIndices(const VocabString *words,
                                VocabIndex *wids, unsigned int max)
        Boolean checkWords(const VocabString *words,
                           VocabIndex *wids, unsigned int max)
        unsigned int length(const VocabIndex *words);
        unsigned int length(const VocabString *words);
        Boolean contains(const VocabIndex *words, VocabIndex word)

# /include
cdef extern from "File.h":
    cdef cppclass File:
        File(const char *name, const char *mode, int exitOnError)
        File(const char *name, const char *mode)
        #File(string& fileStr, int exitOnError = 1, int reserved_length = 0)
        int close()
        Boolean error()
        const char *name
        unsigned int lineno

cdef extern from "ngramiter.h":
    ctypedef unsigned long NgramCount
    cdef cppclass IterableNgramStats:
        Boolean openVocab
        Boolean addSentStart
        Boolean addSentEnd
        Vocab vocab
        IterableNgramStats(Vocab &vocab, unsigned int order)
        unsigned getorder()
        NgramCount *findCount(const VocabIndex *words)
        Boolean read(File &file, unsigned int order, Boolean limitVocab)
        void write(File &file, unsigned int order, Boolean sorted)
        NgramCount sumCounts()
        NgramCount sumCounts(unsigned int order)
        unsigned pruneCounts(NgramCount minCount)
        void setCounts(NgramCount value)
        void setCounts()
        void clear()
        unsigned int countFile(File &file, Boolean weighted)
    cdef cppclass IterableNgramStatsIter:
        IterableNgramStatsIter(IterableNgramStats &ngrams,
                               unsigned int order)
        unsigned int order()
        void init()
        NgramCount *next()
        VocabIndex *current_key()

#
# Helper Function
#

cdef VocabString * char_ptr_array(list_of_strs):
    cdef unsigned int max = len(list_of_strs)
    cdef VocabString *clist
    clist = <VocabString *>malloc(max * sizeof(VocabString))
    cdef int idx
    for idx in range(max):
        clist[idx] = PyString_AsString(list_of_strs[idx])
    return clist

#
# Wrapper Classes
#

cdef class SRILMVocab:
    '''
    A class representing a vocabulary of words.  Each word has an
    index, and this vocabulary object maps between words and their
    indices, and back again.
    '''

    cdef Vocab *vocab

    def __cinit__(self):
        '''
        Constructor.
        '''
        self.vocab = new Vocab()

    def __dealloc__(self):
        del self.vocab

    def get_word(self, index):
        '''
        Gets the word at index `index` in this vocabulary.  Returns None
        if there is no word at the given index.

        Arguments:
        - `index`:
        '''
        rval = self.vocab.getWord(index)
        if rval == NULL:
            return None
        return rval

    def get_words(self, idxs):
        '''
        Gets the words at the indices given in the list `idxs`.  The
        returned list may be shorter than `idxs` if some of the
        indices in the passed list are not found in this vocabulary.

        Arguments:
        - `idxs`:
        '''
        cdef c_array.array cidxs = array('I', idxs)
        cdef unsigned int max = len(idxs)
        cdef VocabString *cwords
        cwords = <VocabString *>malloc(max * sizeof(VocabString))
        max = self.vocab.getWords(cidxs.data.as_uints, cwords, max)
        rwords = []
        cdef int idx
        for idx in range(max):
            rwords.append(str(cwords[idx]))
        free(cwords)
        return rwords

    def get_index(self, word):
        '''
        Gets the index of the given word `word`.  Returns None if the word
        is not included in this vocabulary.

        Arguments:
        - `word`: this should be of type `str` or `bytes` (i.e., do
          any encoding before passing `word` to this method)
        '''
        rval = self.vocab.getIndex(word)
        if rval == Vocab_None:
            return None
        return rval

    def __contains__(self, word):
        '''
        Tests if this vocabulary contains the given word `word`.

        Arguments:
        - `word`: this should be of type `str` or `bytes` (i.e., do
          any encoding before passing `word` to this method)
        '''
        return self.get_index(word) is not None

    def get_indices(self, words):
        '''
        Returns a list of indices into the vocabulary for the passed list
        of words.

        Arguments:
        - `words`: this should be of type `str` or `bytes` (i.e., do
          any encoding before passing `words` to this method)
        '''
        cdef VocabString *cwords = char_ptr_array(words)
        cdef VocabIndex *cidxs
        cdef unsigned int max = len(words)
        cidxs = <VocabIndex*>malloc(max * sizeof(VocabIndex))
        max = self.vocab.getIndices(cwords, cidxs, max, Vocab_None)
        free(cwords)
        ridxs = []
        for idx in range(max):
            ridxs.append(cidxs[idx])
        free(cidxs)
        return ridxs

    def check_words(self, words):
        '''
        This method is like `get_indices` in that it looks up the indices
        associated with the words passed in the list `words`.  The
        method only returns the words' indices if all the words in the
        passed list are included in the vocabulary; otherwise, it
        returns False.

        Arguments:
        - `words`: this should be of type `str` or `bytes` (i.e., do
          any encoding before passing `words` to this method)
        '''
        cdef VocabString *cwords = char_ptr_array(words)
        cdef VocabIndex *cidxs
        cdef unsigned int max = len(words)
        cidxs = <VocabIndex*>malloc(max * sizeof(VocabIndex))
        cdef Boolean rval
        rval = self.vocab.checkWords(cwords, cidxs, max)
        free(cwords)
        ridxs = []
        for idx in range(max):
            ridxs.append(cidxs[idx])
        free(cidxs)
        if rval:
            return ridxs
        else:
            return False

    def num_words(self):
        '''
        Returns the number of words in this vocabulary.
        '''
        return self.vocab.numWords()

    def __len__(self):
        return self.num_words()

    def high_index(self):
        '''
        Returns the index of the last word in this vocabulary.
        '''
        return self.vocab.highIndex()

    def to_lower(self):
        '''
        Indicates whether this vocabulary normalises words for case or
        not.
        '''
        return bool(self.vocab.toLower())

    def unk_is_word(self):
        '''
        Returns true if the unknown word is included in this vocabulary.
        '''
        return bool(self.vocab.unkIsWord())

cdef class Ngrams:
    '''
    A class containing counts of word n-grams.
    '''

    cdef IterableNgramStats *stats
    cdef readonly SRILMVocab vocab
    cdef readonly unsigned int order

    def __cinit__(self, unsigned int order, SRILMVocab vocab = None):
        '''Constructor.'''
        if vocab is None:
            vocab = SRILMVocab()
        self.stats = new IterableNgramStats(dereference(vocab.vocab), order)
        self.vocab = vocab
        self.order = order

    def __dealloc__(self):
        del self.stats

    property open_vocab:
        def __get__(self):
            return bool(self.stats.openVocab)
        def __set__(self, value):
            self.stats.openVocab = 1 if value else 0

    property add_sent_start:
        def __get__(self):
            return bool(self.stats.addSentStart)
        def __set__(self, value):
            self.stats.addSentStart = 1 if value else 0

    property add_sent_end:
        def __get__(self):
            return bool(self.stats.addSentEnd)
        def __set__(self, value):
            self.stats.addSentEnd = 1 if value else 0

    def read(self, filename, order = None, limitVocab = False):
        '''
        Reads the n-gram counts in from file.

        Arguments:
        - `filename`:
        - `order`:
        - `limitVocab`: if this flag is True, this method only reads
          in those n-grams from file which use words already contained
          in this n-gram count object's vocabulary
        '''
        if order is None:
            order = self.order
        cdef File *file = new File(filename, 'r')
        rval = self.stats.read(dereference(file), order, limitVocab)
        del file
        return rval

    def write(self, filename, order = 0, sortNgrams = False):
        '''
        Writes the n-gram counts out to file.

        Arguments:
        - `filename`:
        - `order`: if 0, this method writes all counts to file; if
          `order` is some other value, this method only writes those
          n-grams of length `order` to file.
        - `sortNgrams`: a flag indicating whether to sort the n-grams
          before writing them to file
        '''
        cdef File *file = new File(filename, 'w')
        self.stats.write(dereference(file), order, sortNgrams)
        del file

    def get_order(self):
        '''
        Returns the order (maximum n-gram length) of this object.
        '''
        return self.stats.getorder()

    def count_file(self, filename, textFileHasWeights = False):
        '''
        Counts the n-grams in the given file `filename`.

        Arguments:
        - `filename`:
        - `textFileHasWeights`:
        '''
        cdef File *file = new File(filename, 'r')
        rval = self.stats.countFile(dereference(file), textFileHasWeights)
        del file
        return rval

    #def indices_count(self, idxs):
    #    raise NotImplementedError() # TODO

    def find_count(self, words):
        '''
        Finds the count associated with the n-gram represented by `words`
        in this container.

        Arguments:
        - `words`: a list of `str` objects containing an n-gram
        '''
        # convert the words into indices
        cdef VocabString *cwords = char_ptr_array(words)
        cdef VocabIndex *cidxs
        cdef unsigned int max = len(words)
        cidxs = <VocabIndex*>malloc((max + 1) * sizeof(VocabIndex))
        cdef Boolean rval
        rval = self.vocab.vocab.checkWords(cwords, cidxs, max)
        free(cwords)
        cdef unsigned long *count
        if not rval:
            free(cidxs)
            return 0
        else:
            cidxs[max] = Vocab_None
            count = self.stats.findCount(cidxs)
            free(cidxs)
            if count == NULL:
                return 0
            else:
                return dereference(count)

    def __getitem__(self, words):
        return self.find_count(words)

    def __contains__(self, words):
        return (self.find_count(words) != 0)

    def ngrams(self, order):
        '''
        Generator function over all n-grams of order `order` contained in
        this object.  The function yields tuples like (`ngram`,
        `count`), where `ngram` is a list of `str`s, and `count` is a
        number.

        Arguments:
        - `order`: the order of n-grams to iterate over (1 for
          unigrams, 2 for bigrams, etc.)
        '''
        cdef IterableNgramStatsIter *iter
        cdef unsigned int corder = order
        iter = new IterableNgramStatsIter(dereference(self.stats), corder)
        iter.init()
        cdef NgramCount *count
        cdef VocabIndex *ngram
        cdef unsigned int max = corder
        cdef VocabString *cwords
        cwords = <VocabString *>malloc(max * sizeof(VocabString))
        cdef unsigned int idx
        count = iter.next()
        while count != NULL:
            ngram = iter.current_key()
            max = self.vocab.vocab.getWords(ngram, cwords, corder)
            pngram = []
            for idx in range(max):
                pngram.append(str(cwords[idx]))
            yield (pngram, dereference(count))
            count = iter.next()
        free(cwords)
        del iter
