#!/usr/bin/env python
# -*- coding: ISO-8859-1 -*-
import os
import sys
import re

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
        self._install_lib = install.install_lib
        self._package_base = os.path.join(install.install_data,
                                          self.data_files[0][0])
        self._catalogs = install.catalogs
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

        script_args = { 'env_executable': env_exec,
                        'env_args': env_exec and (' %s' % env_args) or '',
                        'py_executable': py_exec,
                        'lib_path': lib_path,
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


class Install(install):

    user_options = install.user_options + \
                   [('catalogs=', None, 'default SGML catalogs')]

    def initialize_options(self):
        install.initialize_options(self)
        self.catalogs = None


class InstallData(install_data):

    def run(self):
        self.mkpath(self.install_dir)
        print self.data_files
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

