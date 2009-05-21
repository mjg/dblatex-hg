import os
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
        self.adds = None or []
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
        print "\n".join(cmds)
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
            print "probleme"
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
                rc = self.execute(e)
                if rc != 0:
                    print "'%s' failed" % e
                    break
            i = i+1
            done.append("# %s" % c)
        return (done, cmds[i:])

    def _getcommands(self):
        cmds = []
        commits = []
        if self.adds:
            cmds.append("cvs add %s" % " ".join(self.adds))
            commits += self.adds
        if self.dels:
            cmds.append("cvs rm -f %s" % " ".join(self.dels))
            commits += self.dels
        if self.chgs:
            commits += self.chgs

        if commits:
            cmds.append("cvs commit -m '%s' %s" % \
                        (self.desc, " ".join(commits)))
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


def cvscommit(cvs, cset):
    # Get the changeset tag
    tag = ""
    tags = cset.getElementsByTagName("tag")
    if tags: tag = tags[0].getAttribute("name")

    # New CVS command set
    rev = cset.getAttribute("rev")
    cvs.cset = cset.getAttribute("node")
    desc = cset.getElementsByTagName("description")[0]
    desc = desc.childNodes[0].nodeValue
    cvs.newset(desc, tag=tag)
    cvs.log("# rev=%s\n" % rev)

    # Grab the files to add/delete/commit
    files = cset.getElementsByTagName("file")
    for f in files:
        path = f.getAttribute("path")
        mode = f.getAttribute("mode")

        # Ignore Tag machinery changesets
        if path == ".hgtags":
            continue

        if mode == "add":
            dirs = path.split(os.path.sep)[:-1]
            for i in range(0, len(dirs)):
                subdir = os.path.join(*dirs[:i+1])
                cvsd = os.path.join(subdir, "CVS")
                if not(os.path.isdir(cvsd)):
                    if not(subdir in cvs.adds):
                        cvs.adds.append(subdir)
            cvs.adds.append(path)
        elif mode == "del":
            cvs.dels.append(path)
        else:
            cvs.chgs.append(path)

    # Refresh the batch file
    # cvs.flush()


def do_preupdate(ui, repo, parent1="", parent2=""):
    global preupdate_node

    # Remember the current working parent in the case of CVS failure
    p = Popen("hg parents --template '{node}'", shell=True, stdout=PIPE)
    preupdate_node = p.communicate()[0]


def do_update(ui, repo, parent1="", parent2="", error=0):
    global preupdate_node

    # Now call CVS for real
    cvs = CVSSession(batch="cvslog.txt")
    rc = cvs.runbatch("cvslog.txt", replace=True)

    # On trouble come back to known situation
    if rc != 0:
        os.system("hg update -r %s" % preupdate_node)


def cvshook(ui, repo, hooktype="", **kwargs):

    print kwargs
    # return True
    print "***", hooktype
    if hooktype == "preupdate":
        return do_preupdate(ui, repo, **kwargs)

    if hooktype == "update":
        return do_update(ui, repo, **kwargs)

    if hooktype == "pretxnchangegroup":
        cmd = "hg log -r tip:%s --debug --style %s" % (kwargs["node"], style)
        print (cmd)
        p = Popen(cmd, shell=True, stdout=PIPE)
        data = p.communicate()[0]
        print (data)
        #return True

        cvs = CVSSession(batch="cvslog.txt")

        dom3 = parseString("<changegroup>" + data + "</changegroup>")

        csets = dom3.getElementsByTagName("changeset")
        rc = False
        for cset in csets:
            cvscommit(cvs, cset)

        dom3.unlink()
        return rc

    if hooktype == "changegroup":
        pass

    if hooktype == "incoming":
        pass

