from __future__ import print_function

import os
import fnmatch
from subprocess import Popen, PIPE
from xml.dom.minidom import parseString

style = "../xml.style"
preupdate_node = ""
cvssession = None

class CVSSession:

    def __init__(self, adds=None, dels=None, chgs=None, desc="", batch=""):
        self._clearfiles()
        self._log = None
        self.batch = batch
        self.desc = desc
        self.tag = ""
        if self.batch:
            self._log = open(batch, "w")

    def _clearfiles(self):
        self.add_files = None or []
        self.add_dirs = None or []
        self.dels = None or []
        self.chgs = None or []
        self.cmds = None or []

    def newset(self, desc, tag=""):
        self.desc = desc
        self.tag = tag

    def execute(self, cmd):
        return os.system(cmd)

    def log(self, data):
        if self._log:
            self._log.write(data)

    def dumpto(self, dumpfile, close=True):
        cmds = self._getcommands()

        # Add to the batch file
        print("\n".join(cmds))
        f = open(dumpfile, "w")
        f.write("\n".join(cmds) + "\n")
        f.close()
        #if close:
        #    self._log.close()

        # Purge the pending files & update the command list
        #self._clearfiles()
        #self.cmds += cmds

    def runbatch(self, batchfile, replace=True):
        f = open(batchfile)
        lines = f.readlines()
        f.close()

        done, cmds = self.runcommands(lines)

        if replace:
            # Backup
            f = open("%s~" % batchfile, "w")
            f.writelines(lines)
            f.close()
            # Now replace
            f2 = open(batchfile, "w")
            f2.writelines(done)
            if cmds:
                f2.write("# REMAINING\n")
                f2.writelines(cmds)
            f2.close()

        if cmds:
            print("probleme")
            return -1
        else:
            return 0

    def runcommands(self, cmds):
        done = []
        rc = 0
        i = 0
        for c in cmds:
            e = c.split("#")[0].strip()
            if e:
                rc = self.execute(c)
                if rc != 0:
                    print("'%s' failed" % c)
                    break
            i = i+1
            done.append("# %s" % c)
        return (done, cmds[i:])

    def _getcommands(self):
        cmds = []
        commits = []
        if self.add_dirs:
            for d in self.add_dirs:
                cmds.append("cvs add %s" % (d))
        if self.add_files:
            cmds.append("cvs add %s" % " ".join(self.add_files))
            commits += self.add_files
        if self.dels:
            cmds.append("cvs rm -f %s" % " ".join(self.dels))
            commits += self.dels
        if self.chgs:
            commits += self.chgs

        if commits:
            # FIXME: characters with accents    
            desc = self.desc.replace("'", r"'\''")
            desc = desc.replace("#", r"'\#'")
            if "\n" in self.desc:
                # multiline commit logs needs to use a temporary file
                opt = "-F"
                arg = "/tmp/commit.log"
                lines = desc.split("\n")
                l = lines[0]
                cmds.append("echo '%s' > %s" % (l, arg))
                for l in lines[1:]:
                    cmds.append("echo '%s' >> %s" % (l, arg))
            else:
                # use the inline comment option
                opt = "-m"
                arg = "'%s'" % desc
            cmds.append("cvs commit %s %s %s" % \
                        (opt, arg, " ".join(commits)))

        if self.tag and self.tag != "tip":
            cmds.append("cvs tag %s" % (self.tag))
        return cmds

    def run(self, dry_run=False, batch="/tmp/cvsbatch"):
        # FIXME
        self.dumpto(batch)

        # Actually call CVS!
        if not(dry_run):
            rc = self.runbatch(batch)
            if rc != 0:
                raise OSError("exec failed")

    def _file_match(self, filename, pattern_list):
        if not(pattern_list):
            return None

        matchers = [ p for p in pattern_list if fnmatch.fnmatch(filename, p)]
        return matchers

    def from_cset(self, cset, exclude_files=None):
        # Get the changeset tag
        tag = ""
        tags = cset.getElementsByTagName("tag")
        if tags: tag = tags[0].getAttribute("name")

        # New CVS command set
        self.rev = cset.getAttribute("rev")
        self.cset = cset.getAttribute("node")
        desc = cset.getElementsByTagName("description")[0]
        desc = desc.childNodes[0].nodeValue
        self.newset(desc, tag=tag)
        self.log("# rev=%s\n" % self.rev)

        # Grab the files to add/delete/commit
        files = cset.getElementsByTagName("file")
        for f in files:
            path = f.getAttribute("path")
            mode = f.getAttribute("mode")

            # Ignore Tag machinery changesets
            if path == ".hgtags":
                continue

            if self._file_match(path, exclude_files):
                print("Skip '%s'" % (path))
                continue

            if mode == "add":
                dirs = path.split(os.path.sep)[:-1]
                for i in range(0, len(dirs)):
                    subdir = os.path.join(*dirs[:i+1])
                    cvsd = os.path.join(subdir, "CVS")
                    if not(os.path.isdir(cvsd)):
                        if not(subdir in self.add_dirs):
                            self.add_dirs.append(subdir)
                self.add_files.append(path)
            elif mode == "del":
                self.dels.append(path)
            else:
                self.chgs.append(path)

        # Refresh the batch file
        # self.flush()

