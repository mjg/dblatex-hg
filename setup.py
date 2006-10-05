#!/usr/bin/env python
# -*- coding: ISO-8859-1 -*-
import os
import sys
import re
import glob

from distutils.core import setup
from distutils.command.build_scripts import build_scripts
from distutils.command.install_data import install_data
from distutils.command.install import install


#
# Build the command line script
#
class BuildScripts(build_scripts):

    SHELL_SCRIPT = """#!%(env_executable)s%(env_args)s%(py_executable)s
import sys
import os

package_base = r"%(package_base)s"

%(lib_path)s
%(catalogs)s
%(style_set)s
from %(package_path)s import %(package)s
%(package)s.main(base=package_base)
"""

    CATALOGS = """cat = os.environ.get("SGML_CATALOG_FILES")
if cat:
    cat += ":%s"
else:
    cat = "%s"
os.environ["SGML_CATALOG_FILES"] = cat
"""

    def run(self):
        """
        Create the proper script for the current platform.
        """
        if not self.scripts:
            return

        # The script can only work with package data
        self.data_files = self.distribution.data_files
        if not(self.data_files):
            return

        if self.dry_run:
            return

        # Ensure the destination directory exists
        self.mkpath(self.build_dir)

        # Data useful for building the script
        install = self.distribution.get_command_obj("install")
        if not(install.install_data):
            return

        self._install_lib = os.path.normpath(install.install_lib)
        self._package_base = os.path.join(install.install_data,
                                          self.data_files[0][0])
        self._catalogs = install.catalogs
        self._style = install.style
        print self._package_base

        # Build the command line script
        self.build_script()

    def build_script(self):
        script_name = self.scripts[0]

        # prepare args for the bang path at the top of the script
        ENV_BIN = '/usr/bin/env'
        if os.name == 'posix':
            # Some Solaris platforms may not have an 'env' binary.
            # If /usr/bin/env exists, use '#!/usr/bin/env python'
            # otherwise, use '#!' + sys.executable
            env_exec = os.path.isfile(ENV_BIN) and \
                os.access(ENV_BIN, os.X_OK) and ENV_BIN or ''
            env_args = ''
            py_exec = env_exec and 'python' or sys.executable
        else:
            # shouldn't matter on non-POSIX; we'll just use defaults
            env_exec = ENV_BIN
            env_args = ''
            py_exec = 'python'

        # Just help for non standard installation paths
        if self._install_lib in sys.path:
            lib_path = ""
        else:
            lib_path = "sys.path.append(r\"%s\")" % self._install_lib

        if self._catalogs:
            catalogs = self.CATALOGS % (self._catalogs, self._catalogs)
        else:
            catalogs = ""

        if self._style:
            style_set = "sys.argv.insert(1, '-T%s')" % self._style
        else:
            style_set = ""

        script_args = { 'env_executable': env_exec,
                        'env_args': env_exec and (' %s' % env_args) or '',
                        'py_executable': py_exec,
                        'lib_path': lib_path,
                        'style_set': style_set,
                        'package': "dblatex",
                        'package_path': "dbtexmf.dblatex",
                        'catalogs': catalogs,
                        'package_base': self._package_base }

        script = self.SHELL_SCRIPT % script_args
        script_name = os.path.basename(script_name)
        outfile = os.path.join(self.build_dir, script_name)
        fd = os.open(outfile, os.O_WRONLY|os.O_CREAT|os.O_TRUNC, 0755)
        os.write(fd, script)
        os.close(fd)


def find_programs(utils):
    contrib_path = os.path.join("lib", "contrib")
    sys.path.append(contrib_path)
    from which import which
    util_paths = {}
    missed = []
    for util in utils:
        try:
            path = which.which(util)
            util_paths[util] = path
        except which.WhichError:
            missed.append(util)
    sys.path.remove(contrib_path)
    return (util_paths, missed)
        

class Install(install):

    user_options = install.user_options + \
                   [('catalogs=', None, 'default SGML catalogs'),
                    ('nodeps', None, 'don\'t check the dependencies'),
                    ('style=', None, 'default style to use')]

    def initialize_options(self):
        install.initialize_options(self)
        self.catalogs = None
        self.nodeps = None
        self.style = None

    def check_util_dependencies(self):
        found, missed = find_programs(("xsltproc", "latex",
                                       "pdflatex", "kpsewhich"))
        for util in found:
            print "+checking %s... yes" % util
        for util in missed:
            print "+checking %s... no" % util
        if missed:
            raise OSError("not found: %s" % ", ".join(missed))

    def check_latex_dependencies(self):
        # Find the Latex files from the package
        stys = []
        for root, dirs, files in os.walk('latex/'):
            stys += glob.glob(os.path.join(root, "*.sty"))
        if stys:
            own_stys = [os.path.basename(s)[:-4] for s in stys]
        else:
            own_stys = []

        # Find the used packages
        used_stys = []
        re_sty = re.compile(r"\\usepackage\s*\[?.*\]?{(\w+)}")
        for sty in stys:
            f = open(sty)
            for line in f:
                line = line.split("%")[0]
                m = re_sty.search(line)
                if m: used_stys.append(m.group(1))
            f.close()

        # Now look if they are found
        found_stys = []
        mis_stys = []
        used_stys.sort()

        # Dirty...
        try:
            used_stys.remove("truncate")
        except:
            pass

        for sty in used_stys:
            if sty in found_stys:
                continue
            status = "+checking %s... " % sty
            if sty in own_stys:
                status += "found in package"
                found_stys.append(sty)
                print status
                continue
            ios = os.popen2("kpsewhich %s.sty" % sty)
            if ios[1].readlines():
                status += "yes"
                found_stys.append(sty)
            else:
                status += "no"
                mis_stys.append(sty)
            print status
            
        if mis_stys:
            raise OSError("not found: %s" % ", ".join(mis_stys))

    def run(self):
        if not(self.nodeps):
            try:
                self.check_util_dependencies()
                self.check_latex_dependencies()
            except Exception, e:
                print >>sys.stderr, "Error: %s" % e
                sys.exit(1)

        install.run(self)


class InstallData(install_data):

    def run(self):
        self.mkpath(self.install_dir)
        for install_base, dirs in self.data_files:
            basedir = os.path.join(self.install_dir, install_base)
            for dir in dirs:
                self.copy_tree(dir, os.path.join(basedir, dir))


def get_version():
    sys.path.append("lib")
    from dbtexmf.dblatex import dblatex
    d = dblatex.DbLatex(base=os.getcwd())
    sys.path.remove("lib")
    return d.get_version()


if __name__ == "__main__":
    setup(name="dblatex",
      version=get_version(),
      description='DocBook to LaTeX/ConTeXt Publishing',
      author='Benoît Guillon',
      author_email='marsgui@users.sourceforge.net',
      url='http://dblatex.sf.net',
      packages=['dbtexmf',
                'dbtexmf.core',
                'dbtexmf.dblatex',
                'dbtexmf.dblatex.grubber'],
      package_dir={'dbtexmf':'lib/dbtexmf'},
      data_files=[('share/dblatex', ['xsl', 'latex', 'docs'])],
      scripts=['scripts/dblatex'],
      cmdclass={'build_scripts': BuildScripts,
                'install': Install,
                'install_data': InstallData}
     )

