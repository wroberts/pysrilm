/*
 * ngramiter.h
 *
 * Iterator over n-grams of a certain length.
 *
 * Copyright (c) 2015 Will Roberts.
 */

#ifndef _NGRAMITER_H_
#define _NGRAMITER_H_

#include "NgramStats.h"

class IterableNgramStatsIter;
class IterableNgramStats : public NgramStats
{
    friend class IterableNgramStatsIter;
public:
    IterableNgramStats(Vocab &vocab, unsigned int order)
        : NgramStats(vocab, order) {};
    virtual ~IterableNgramStats() {};
};

class IterableNgramStatsIter
{
public:
    IterableNgramStatsIter(IterableNgramStats &ngrams,
                           unsigned int order)
    {
        myOrder = order;
        keys = new VocabIndex[order+1];
        memset(keys, 0, order * sizeof(*keys));
        Map_noKey(keys[order]);
        myIter = new TrieIter2<VocabIndex,NgramCount>(ngrams.counts, keys, order, 0);
    };
    virtual ~IterableNgramStatsIter() {
        if (keys) delete keys;
        if (myIter) delete myIter;
    };
    unsigned int order() {return myOrder;};
    void init() { myIter->init(); };
    NgramCount *next()
	{
        Trie<VocabIndex,NgramCount> *node = myIter->next();
        return node ? &(node->value()) : 0;
    };
    VocabIndex *current_key()
    {
        return keys;
    };
protected:
    unsigned int myOrder;
    VocabIndex *keys;
    TrieIter2<VocabIndex,NgramCount> *myIter;
};

#endif /* _NGRAMITER_H_ */
