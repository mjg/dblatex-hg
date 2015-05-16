#!/usr/bin/python
import sys
import subprocess

def main():
    """
    Script simple qui execute tout une liste de commandes mises dans un fichier.
    Cela permet de faire du pas a pas, d'executer tout un ensemble de commandes,
    de les relancer si elles echouent, etc.
    """
    from optparse import OptionParser
    parser = OptionParser(usage="calcul_pret_poste.py [options]")
    parser.add_option("-f", "--from-line",
                      help="First line of the commands to run")
    parser.add_option("-t", "--to-line",
                      help="Last line of the commands to run")
    parser.add_option("-l", "--line",
                      help="Single line of the commands to run")
    parser.add_option("-n", "--dry_run", action="store_true",
                      help="Show the commands but don't run them")

    (options, args) = parser.parse_args()

    command_file = open(args[0])
    commands = command_file.readlines()

    first_line = 0
    last_line = 0
    if options.from_line:
        first_line = int(options.from_line)
    if options.to_line:
        last_line = int(options.to_line)
    if options.line:
        first_line = int(options.line)
        last_line = int(options.line)

    if first_line == 0 and last_line == 0:
        print "No line to run? use options to specify commands"
        sys.exit(0)
    
    if first_line == 0:
        first_line = 1
    if last_line == 0:
        last_line = len(commands)

    for n in range(first_line-1, last_line):
        command = commands[n].strip()
        print command
        if not(options.dry_run):
            rc = subprocess.call(command, shell=True)
            if rc != 0:
                print >>sys.stderr, "Stop on error: %d" % rc
                break


if __name__ == "__main__":
    main()
