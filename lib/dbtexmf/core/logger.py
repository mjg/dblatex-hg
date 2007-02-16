import logging

def logger(logname, level):
    loglevels = { -2: logging.ERROR-1,
                  -1: logging.WARNING-1,
                   0: logging.INFO-1,
                   1: logging.DEBUG-1 }

    log = logging.getLogger(logname)
    log.setLevel(loglevels[level])
    console = logging.StreamHandler()
    format = logging.Formatter("%(message)s")
    console.setFormatter(format)
    log.addHandler(console)
    return log

