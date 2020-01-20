#!/usr/bin/python
from __future__ import print_function

import os
import sys
import glob
import shutil
import subprocess
from subprocess import Popen, PIPE
from xml.dom.minidom import parseString

"""
Ce script a ete developpe pour pouvoir modifier l'auteur de toutes les 
modifications faites dans le passe avec Mercurial avec un mauvais nom.
Les etapes pour mettre a jour le repository de dblatex sous Sourceforge 
(changement d'auteur 'ben' en 'marsgui') :

1. Clonage du repository local de reference :
   $ hg clone /path/to/dblatex dblatex_proxy

2. Modification de l'auteur de tous les changesets jusqu'au plus loin possible,
   a savoir la revision 2 (en dur dans le script) :
   $ cd dblatex_proxy
   $ python hgset_fix.py -d changesets.xml -ipua -c list_cmd 
   $ run_command.py -f1 list_cmd

3. Si tout se passe bien tous les changesets sont gardes avec un "User" mis
   a marsgui, sans changement de date, avec les tags d'origine :

   $ hg log|more
    changeset:   602:3a6f41c28bb9
    tag:         tip
    user:        marsgui
    date:        Fri May 15 17:36:08 2015 +0200
    summary:     Added tag v0_3_6 for changeset 9af4ebd8d1f1

    changeset:   601:9af4ebd8d1f1
    tag:         v0_3_6
    user:        marsgui
    date:        Fri May 15 17:36:08 2015 +0200
    summary:     Change log for release 0.3.6.
    ...

4. Injecter ces changements dans le repository de Sourceforge. Il faut forcer
   (-f) car cela cree deux branches :

   $ hg push -f ssh://marsgui@hg.code.sf.net/p/dblatex/dblatex

5. Se logguer sous sourceforge pour nettoyer le repository en supprimant les
   anciens changesets (au nom de 'ben'). Comme ces changesets sont dans une
   branche dediee, il suffit de supprimer tous les changesets a partir de la
   premiere revision de cette branche (rev 2):

   $ ssh -t marsgui,dblatex@shell.sourceforge.net create
   ...
   $ cd /home/hg/p/dblatex/dblatex
   (ajouter dans le ~/.hgrc l'extension mq pour pouvoir utiliser 'strip')
   $ hg strip -r 2
   $ ^D

6. Recreer un repository proxy clone a partir du repository de sourceforge
   nettoye :
   
   $ hg clone ssh://marsgui@hg.code.sf.net/p/dblatex/dblatex dblatex_proxy2

"""

def exec_command(cmd):
    if isinstance(cmd, list):
        cmd = " ".join(cmd)
    print(cmd)
    subprocess.call(cmd, shell=True)


class HgChangeset:
    def __init__(self):
        self.rev = ""
        self.node = ""
        self.desc = ""
        self.date = ""
        self.files_add = []
        self.files_del = []
        self.files_chg = []
        self.files_spe = []
        self.parents = []
        self.branches = []
        self.tags = []
        self.extra = ""

    def normal_files(self):
        return len(self.files_add+self.files_del+self.files_chg)

    def from_xml(self, cset):
        # Get the changeset tags
        tags = cset.getElementsByTagName("tag")
        for tag in tags:
            self.tags.append(tag.getAttribute("name"))

        # Get main data
        self.rev = cset.getAttribute("rev")
        self.node = cset.getAttribute("node")
        self.date = cset.getAttribute("date")
        desc = cset.getElementsByTagName("description")[0]
        desc = desc.childNodes[0].nodeValue
        self.desc = desc

        # Grab the files to add/delete/commit
        files = cset.getElementsByTagName("file")
        for f in files:
            path = f.getAttribute("path")
            mode = f.getAttribute("mode")

            # Ignore Tag machinery changesets
            if path == ".hgtags":
                self.files_spe.append(path)
                continue

            if mode == "add":
                self.files_add.append(path)
            elif mode == "del":
                self.files_del.append(path)
            else:
                self.files_chg.append(path)


class HgLog:
    xml_style = """\
#header = '<?xml version="1.0" encoding="UTF-8" ?>\\n<repository name="{repo}">\\n\\n'
#footer = '\\n</repository>\\n'
changeset = '<changeset rev="{rev}" node="{node|escape}" date="{date|hgdate|escape}">\\n{parents}{branches}{tags}\t<author name="{author|person|escape}" email="{author|email|escape}" />\\n\\t<description>{desc|strip|escape}</description>\\n\\t<files>\\n{files}{file_adds}{file_dels}{file_copies}    </files>\\n</changeset>\\n'
#start_files = '    <files>\\n'
file     = '\\t<file path="{file|escape}" />\\n'
file_add = '\\t<file path="{file_add|escape}" mode="add" />\\n'
file_del = '\\t<file path="{file_del|escape}" mode="del" />\\n'
file_copy= '\\t<file path="{file_copy|escape}" mode="copy" src="{source}" />\\n'
#end_files = '    </files>\\n'
parent = '    <parent rev="{rev}" />\\n'
branch = '    <branch name="{branch|escape}" />\\n'
tag    = '    <tag name="{tag|escape}" />\\n'
extra  = '    <extra key="{key|escape}" value="{value|escape}" />\\n'
"""

    def __init__(self):
        self.changesets = []

    def get_changesets(self, ctype=""):
        csets = []
        for cset in self.changesets:
            if not(ctype):
                csets.append(cset)
            elif ctype == ".hgtags":
                if cset.normal_files() == 0 and (".hgtags" in cset.files_spe):
                    csets.append(cset)
        return csets

    def fromfile(self, xmlsetfile):
        lines = open(xmlsetfile).readlines()
        data = "".join(lines)
        self.fromdata(data)

    def create(self, from_node="2", to_node="tip", xmlsetfile="",
               exclude_files=None):
        # On cree d'abord the style XML pour recuperer les log
        style = "/tmp/xml.style"
        f = open(style, "w")
        f.write(self.xml_style)
        f.close()

        # Recuperation du log
        cmd = "hg log -r %s:%s --debug --style %s" % (from_node, to_node, style)
        print (cmd)
        p = Popen(cmd, shell=True, stdout=PIPE)
        data = p.communicate()[0]

        # On l'exploite
        d = data.decode("utf8").encode("ascii", "ignore")
        data = d.replace(u'\xa0','')
        data = "<changegroup>" + data + "</changegroup>"
        self.fromdata(data, xmlsetfile=xmlsetfile)

    def fromdata(self, data, xmlsetfile=""):
        dom3 = parseString(data)
        if xmlsetfile:
            dom3.writexml(open(xmlsetfile, "w"))

        csets = dom3.getElementsByTagName("changeset")
        for cset in csets:
            hgcset = HgChangeset()
            hgcset.from_xml(cset) #, exclude_files=exclude_files)
            #if hgcset.node == from_node:
            #    continue
            self.changesets.append(hgcset)

        dom3.unlink()


def change_patch_user(patch_dir, user_new):
    patch_files = glob.glob(os.path.join(patch_dir, "*.diff"))

    for pfile in patch_files:
        print("Change user of %s patch file to '%s'" % (pfile, user_new))
        change_patch_header(pfile, "User", user_new)


def change_patch_header(pfile, field, value):
    pfile_ori = open(pfile)
    pfile_new = open(pfile + ".new", "w")
    for line in pfile_ori:
        if line.startswith("# %s " % (field)):
            line = "# %s %s\n" % (field, value)
        pfile_new.write(line)
    pfile_ori.close()
    pfile_new.close()
    shutil.move(pfile + ".new", pfile)


def reapply_patch_commands(patch_dir, hglog, user=""):
    series_file = os.path.join(patch_dir, "series")
    commands = []

    # Pour que ce soit plus simple, on se fait un dictionnaire par fichier diff
    # des changesets
    diff_changesets = {}
    for cset in hglog.changesets:
        for tag in cset.tags:
            if (".diff" in tag):
                diff_changesets[tag] = cset

    # Maintenant on applique les changeset dans l'ordre initial
    for line in open(series_file):
        diff_file = line.strip()
        cset = diff_changesets.get(diff_file, None)
        if not(cset):
            continue

        # On supprime les patchs des fichiers speciaux (.hgtags)
        if cset.normal_files() == 0:
            cmd = ["hg", "qdelete", diff_file]
            commands.append(cmd)
            print(" ".join(cmd))
            continue
        
        # On applique le patch
        cmd = ["hg", "qpush", diff_file]
        commands.append(cmd)
        print(" ".join(cmd))

        # S'il est lie a un(des) tag(s) on les applique
        tags = []
        for tag in cset.tags:
            if tag != diff_file and not(tag in ("qbase", "tip", "qtip")):
                tags.append(tag)

        if tags:
            cmd = ["hg", "qfinish", "-a"]
            commands.append(cmd)
            print(" ".join(cmd))
            cmd = ["hg", "tag"]
            if user:
                cmd = cmd + ["-u", user]
            cmd = cmd + tags
            commands.append(cmd)
            print(" ".join(cmd))
            # On veut antidater le changeset apparu sur .hgtags 
            # lorsque que l'on a ajoute le tag. C'est un peu complexe, donc
            # on rappelle ce script pour cette action avec la date de ce dernier
            # changeset tagge
            cmd = ["python", __file__,
                   "--hgtags-date", cset.date]
            commands.append(cmd)
            print(" ".join(cmd))
    
    # Si la derniere commande n'est pas un 'qfinish' on en ajoute une pour
    # terminer proprement
    if commands and not("qfinish" in commands[-1]):
        cmd = ["hg", "qfinish", "-a"]
        commands.append(cmd)

    return commands


def change_hgtags_date(patch_dir, hglog, date_new):
    # - On retrouve la revision du dernier changeset lie a l'ajout de tag
    # - On recupere le patch correspondant a ce changeset
    # - On retire le patch et on change sa date a <date_new>
    # - On reapplique le patch
    csets = hglog.get_changesets(ctype=".hgtags")
    pfile = "ht.diff"
    if not(csets):
        print("No .hgtags changeset found in log history", file=sys.stderr)
        return
    cset = csets[-1]
    if not("tip" in cset.tags):
        print("Expect the .hgtags changeset is the last one", file=sys.stderr)
        return
    cmd = ["hg", "qimport", "-n", pfile, "-r", cset.rev]
    exec_command(cmd)
    cmd = ["hg", "qpop"]
    exec_command(cmd)
    change_patch_header(os.path.join(patch_dir, pfile), "Date", date_new)
    cmd = ["hg", "qpush", pfile]
    exec_command(cmd)


def write_commands(outfile, commands):
    for command in commands:
        for i in range(0, len(command)):
            if (" " in command[i]):
                command[i] = "'" + command[i] + "'"
        outfile.write(" ".join(command) + "\n")


def main():
    from optparse import OptionParser
    parser = OptionParser(usage="%s [options] [PATCHDIR]" % sys.argv[0])
    parser.add_option("-i", "--qimport", action="store_true",
                      help="Build the patch set")
    parser.add_option("-d", "--dump-changeset",
                      help="Write the target changeset file")
    parser.add_option("-l", "--load-changeset",
                      help="Read the target changeset file")
    parser.add_option("-p", "--qpop", action="store_true",
                      help="Pop the patch set")
    parser.add_option("-u", "--change-user", action="store_true",
                      help="Change the username in patchs")
    parser.add_option("-a", "--apply-patch", action="store_true",
                      help="Apply the patch set")
    parser.add_option("-c", "--output-command-file",
                      help="Write the commands to a file")
    parser.add_option("--hgtags-date",
                      help="Fix the last .hgtags changeset date")

    (options, args) = parser.parse_args()

    # On reprend tous les patchs des changesets
    if options.qimport:
        exec_command("hg qimport -r 2:tip")

    # On recupere les changeset pour retrouver les tags applicables vs patchs
    hglog = HgLog()
    if options.dump_changeset:
        hglog.create(xmlsetfile=options.dump_changeset)
    elif options.load_changeset:
        hglog.fromfile(xmlsetfile=options.load_changeset)
    elif options.hgtags_date:
        hglog.create()
    else:
        print("A changeset is needed: -c or -l required", file=sys.stderr)
        sys.exit(1)

    if options.change_user or options.apply_patch or options.hgtags_date:
        if len(args) == 0:
            patch_dir = ".hg/patches"
            print("The patches dir is required: use default (%s)" % (patch_dir), file=sys.stderr)
        else:
            patch_dir = args[0]
        user_new = "marsgui"

    # Cas particulier ou on fixe la date de fichiers speciaux
    if options.hgtags_date:
        change_hgtags_date(patch_dir, hglog, options.hgtags_date)
        sys.exit(0)

    # On retire les patchs appliques
    if options.qpop:
        exec_command("hg qpop -a")

    # Maintenant on modifie l'utilisateur des patchs
    if options.change_user:
        change_patch_user(patch_dir, user_new)

    # On rapplique les patchs un par un pour ne pas perdre les tags
    if options.apply_patch:
        commands = reapply_patch_commands(patch_dir, hglog, user_new)
        if options.output_command_file:
            fcmd = open(options.output_command_file, "w")
            write_commands(fcmd, commands)
            fcmd.close()
        else:
            write_commands(sys.stdout, commands)


if __name__ == "__main__":
    main()
