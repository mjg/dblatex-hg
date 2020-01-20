from __future__ import print_function

import sys
from push_remote import hg_export_patches


def main():
    from optparse import OptionParser
    parser = OptionParser(usage="%s [options]" % sys.argv[0])
    parser.add_option("-s", "--source",
                      help="Incomming Source repository")
    parser.add_option("-d", "--dest",
                      help="Destination repository")
    parser.add_option("-O", "--patch-dir",
                      help="Directory containing the export patches")

    (options, args) = parser.parse_args()

    repo_incoming = ""
    repo_dest = ""
    patch_dir = ""

    if options.source:
        repo_incoming = options.source
    if options.dest:
        repo_dest = options.dest
    if options.patch_dir:
        patch_dir = options.patch_dir

    if (not(repo_incoming) or not(repo_dest) or not(patch_dir)):
        print("Missing options")
        sys.exit(1)

    hg_export_patches(repo_incoming, repo_dest, patch_dir, add_source=True)

if __name__ == "__main__":
    main()

