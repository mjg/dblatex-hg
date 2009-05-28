#
# Dblatex Error Handler wrapper providing:
# - The ErrorHandler class definition, that must be the parent of any actual
#   error handler.
# - A general API.
#

class ErrorHandler:
    """
    Object in charge to handle any error occured during the dblatex
    transformation process. The first mandatory argument is the <object>
    that signaled the error.
    """
    def __init__(self):
        pass

    def signal(self, object, *args, **kwargs):
        pass


_current_handler = None

#
# Dblatex Error Handler API
#
# In a complex use of the API, a locking mechanism (thread.lock) should
# be used. The current implementation assumes that setup is done before
# any get().
#
def get_errhandler():
    global _current_handler
    # If nothing set, use a default handler that does nothing
    if not(_current_handler):
        _current_handler = ErrorHandler()
    return _current_handler

def set_errhandler(handler):
    global _current_handler
    if not(isinstance(handler, ErrorHandler)):
        raise ValueError("%s is not an ErrorHandler" % handler)
    _current_handler = handler

def signal_error(*args, **kwargs):
    get_errhandler().signal(*args, **kwargs)

