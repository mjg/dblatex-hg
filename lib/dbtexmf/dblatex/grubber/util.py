# This file is part of Rubber and thus covered by the GPL
# (c) Emmanuel Beffara, 2002--2006
"""
This module contains utility functions and classes used by the main system and
by the modules for various tasks.
"""

import md5
import os


def md5_file(fname):
    """
    Compute the MD5 sum of a given file.
    """
    m = md5.new()
    file = open(fname)
    for line in file.readlines():
        m.update(line)
    file.close()
    return m.digest()


class Watcher:
    """
    Watch for any changes of the files to survey, by checking the file MD5 sums.
    """
    def __init__(self):
        self.files = {}

    def watch(self, file):
        if os.path.exists(file):
            self.files[file] = md5_file(file)
        else:
            self.files[file] = None

    def update(self):
        """
        Update the MD5 sums of all files watched, and return the name of one
        of the files that changed, or None of they didn't change.
        """
        changed = None
        for file in self.files.keys():
            if os.path.exists(file):
                new = md5_file(file)
                if self.files[file] != new:
                    changed = file
                self.files[file] = new
        return changed

