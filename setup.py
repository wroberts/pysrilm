#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
setup.py
(c) Will Roberts   9 June, 2015

Setup script for pysrilm.
'''

from Cython.Build import cythonize
from codecs import open
from os import path
from setuptools import setup, Extension
import sys

HERE = path.abspath(path.dirname(__file__))

# Get the long description from the relevant file
with open(path.join(HERE, 'README.rst'), encoding='utf-8') as f:
    LONG_DESCRIPTION = f.read()

ext_modules=[
    Extension("srilm",
              sources=["srilm.pyx",
                       'srilm/include/Array.cc',
                       'srilm/include/CachedMem.cc',
                       'srilm/include/IntervalHeap.cc',
                       'srilm/include/LHash.cc',
                       'srilm/include/Map.cc',
                       'srilm/include/Map2.cc',
                       #'srilm/include/NgramStats.cc',
                       'srilm/include/SArray.cc',
                       'srilm/include/Trellis.cc',
                       'srilm/include/Trie.cc',
                       'srilm/misc/src/Debug.cc',
                       'srilm/misc/src/File.cc',
                       'srilm/misc/src/MStringTokUtil.cc',
                       'srilm/misc/src/fake-rand48.c',
                       'srilm/misc/src/fcheck.c',
                       'srilm/misc/src/option.c',
                       #'srilm/misc/src/tclmain.cc',
                       #'srilm/misc/src/testFile.cc',
                       'srilm/misc/src/tls.cc',
                       'srilm/misc/src/tserror.cc',
                       'srilm/misc/src/version.c',
                       'srilm/misc/src/zio.c',
                       #'srilm/misc/src/ztest.c',
                       'srilm/lm/src/matherr.c',
                       'srilm/lm/src/Prob.cc',
                       'srilm/lm/src/Counts.cc',
                       'srilm/lm/src/XCount.cc',
                       'srilm/lm/src/Vocab.cc',
                       'srilm/lm/src/VocabMap.cc',
                       'srilm/lm/src/VocabMultiMap.cc',
                       'srilm/lm/src/VocabDistance.cc',
                       'srilm/lm/src/SubVocab.cc',
                       'srilm/lm/src/MultiwordVocab.cc',
                       'srilm/lm/src/TextStats.cc',
                       'srilm/lm/src/LM.cc',
                       'srilm/lm/src/LMClient.cc',
                       'srilm/lm/src/LMStats.cc',
                       'srilm/lm/src/RefList.cc',
                       'srilm/lm/src/Bleu.cc',
                       'srilm/lm/src/NBest.cc',
                       'srilm/lm/src/NBestSet.cc',
                       'srilm/lm/src/NgramLM.cc',
                       'srilm/lm/src/NgramStatsInt.cc',
                       'srilm/lm/src/NgramStatsShort.cc',
                       'srilm/lm/src/NgramStatsLong.cc',
                       'srilm/lm/src/NgramStatsLongLong.cc',
                       'srilm/lm/src/NgramStatsFloat.cc',
                       'srilm/lm/src/NgramStatsDouble.cc',
                       'srilm/lm/src/NgramStatsXCount.cc',
                       'srilm/lm/src/NgramProbArrayTrie.cc',
                       'srilm/lm/src/NgramCountLM.cc',
                       'srilm/lm/src/MSWebNgramLM.cc',
                       'srilm/lm/src/Discount.cc',
                       'srilm/lm/src/ClassNgram.cc',
                       'srilm/lm/src/SimpleClassNgram.cc',
                       'srilm/lm/src/DFNgram.cc',
                       'srilm/lm/src/SkipNgram.cc',
                       'srilm/lm/src/HiddenNgram.cc',
                       'srilm/lm/src/HiddenSNgram.cc',
                       'srilm/lm/src/VarNgram.cc',
                       'srilm/lm/src/DecipherNgram.cc',
                       'srilm/lm/src/TaggedVocab.cc',
                       'srilm/lm/src/TaggedNgram.cc',
                       'srilm/lm/src/TaggedNgramStats.cc',
                       'srilm/lm/src/StopNgram.cc',
                       'srilm/lm/src/StopNgramStats.cc',
                       'srilm/lm/src/MultiwordLM.cc',
                       'srilm/lm/src/NonzeroLM.cc',
                       'srilm/lm/src/BayesMix.cc',
                       'srilm/lm/src/LoglinearMix.cc',
                       'srilm/lm/src/AdaptiveMix.cc',
                       'srilm/lm/src/AdaptiveMarginals.cc',
                       'srilm/lm/src/CacheLM.cc',
                       'srilm/lm/src/DynamicLM.cc',
                       'srilm/lm/src/HMMofNgrams.cc',
                       'srilm/lm/src/WordAlign.cc',
                       'srilm/lm/src/WordLattice.cc',
                       'srilm/lm/src/WordMesh.cc',
                       'srilm/lm/src/simpleTrigram.cc',
                       'srilm/lm/src/LMThreads.cc',
                       'srilm/lm/src/MEModel.cc',
                       'srilm/lm/src/hmaxent.cc',
                       'srilm/dstruct/src/Array.cc',
                       'srilm/dstruct/src/BlockMalloc.cc',
                       'srilm/dstruct/src/CachedMem.cc',
                       'srilm/dstruct/src/DStructThreads.cc',
                       'srilm/dstruct/src/IntervalHeap.cc',
                       'srilm/dstruct/src/LHash.cc',
                       'srilm/dstruct/src/LHashTrie.cc',
                       #'srilm/dstruct/src/Map.cc',
                       'srilm/dstruct/src/Map2.cc',
                       'srilm/dstruct/src/MemStats.cc',
                       'srilm/dstruct/src/SArray.cc',
                       'srilm/dstruct/src/SArrayTrie.cc',
                       'srilm/dstruct/src/Trie.cc',
                       #'srilm/dstruct/src/benchHash.cc',
                       'srilm/dstruct/src/maxalloc.c',
                       'srilm/dstruct/src/qsort.c',
                       #'srilm/dstruct/src/testArray.cc',
                       #'srilm/dstruct/src/testBlockMalloc.cc',
                       #'srilm/dstruct/src/testCachedMem.cc',
                       #'srilm/dstruct/src/testFloatMap.cc',
                       #'srilm/dstruct/src/testHash.cc',
                       #'srilm/dstruct/src/testMap.cc',
                       #'srilm/dstruct/src/testMap2.cc',
                       #'srilm/dstruct/src/testSizes.cc',
                       #'srilm/dstruct/src/testTrie.cc',
                   ],
              libraries=['z', 'iconv'],
              include_dirs=['srilm/lm/src', 'srilm/include', '/opt/local/include'],
              language="c++",
              define_macros=[
                  ('HAVE_ZOPEN', 1),
                  ('INSTANTIATE_TEMPLATES', 1),
                  #('NO_BLOCK_MALLOC', 1),
              ]
    )
]

setup(
    name='pysrilm',
    version='0.0.1',
    description='Python Interface to SRILM',
    long_description=LONG_DESCRIPTION,
    
    # The project's main homepage.
    url='https://github.com/wroberts/pysrilm',

    # Author details
    author='Will Roberts',
    author_email='wildwilhelm@gmail.com',

    # Choose your license
    license='MIT',

    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 3 - Alpha',

        # Indicate who your project is intended for
        'Intended Audience :: Developers',
        'Topic :: Text Processing',
        'Natural Language :: English',

        # Pick your license as you wish (should match "license" above)
        'License :: OSI Approved :: MIT License',

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
    ],

    # What does your project relate to?
    keywords='ngram statistics language model',

    ext_modules = cythonize(ext_modules),

    install_requires=[],
)
